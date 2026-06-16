import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "npm:@supabase/supabase-js@2";
import { badRequest, json } from "../_shared/http.ts";

const FCM_URL = "https://fcm.googleapis.com/v1/projects/fudi-abf43/messages:send";
const OAUTH_URL = "https://oauth2.googleapis.com/token";
const FCM_SCOPE = "https://www.googleapis.com/auth/firebase.messaging";

const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
const serviceAccountRaw = Deno.env.get("FCM_SERVICE_ACCOUNT");

const supabase = createClient(supabaseUrl, serviceRoleKey, {
  auth: { persistSession: false, autoRefreshToken: false },
});

interface SendPushRequest {
  user_ids: string[];
  title: string;
  body: string;
  data?: Record<string, string>;
  type: string;
}

interface DeviceTokenRow {
  id: string;
  user_id: string;
  token: string;
  platform: "ios" | "android" | "web";
}

function base64UrlEncode(data: ArrayBuffer): string {
  const bytes = new Uint8Array(data);
  let binary = "";
  for (let i = 0; i < bytes.length; i++) {
    binary += String.fromCharCode(bytes[i]);
  }
  return btoa(binary)
    .replace(/\+/g, "-")
    .replace(/\//g, "_")
    .replace(/=+$/, "");
}

async function signRsaSha256(
  privateKeyPem: string,
  data: string,
): Promise<string> {
  const pemHeader = "-----BEGIN PRIVATE KEY-----";
  const pemFooter = "-----END PRIVATE KEY-----";
  const pemContents = privateKeyPem
    .replace(pemHeader, "")
    .replace(pemFooter, "")
    .replace(/\s/g, "");

  const binaryDer = Uint8Array.from(atob(pemContents), (c) => c.charCodeAt(0));

  const privateKey = await crypto.subtle.importKey(
    "pkcs8",
    binaryDer.buffer,
    { name: "RSASSA-PKCS1-v1_5", hash: "SHA-256" },
    false,
    ["sign"],
  );

  const encoded = new TextEncoder().encode(data);
  const signature = await crypto.subtle.sign(
    { name: "RSASSA-PKCS1-v1_5" },
    privateKey,
    encoded,
  );

  return base64UrlEncode(signature);
}

function parseServiceAccount(
  raw: string,
): { clientEmail: string; privateKey: string } | null {
  try {
    const parsed = JSON.parse(raw);
    if (!parsed.client_email || !parsed.private_key) return null;
    return { clientEmail: parsed.client_email, privateKey: parsed.private_key };
  } catch {
    return null;
  }
}

async function getAccessToken(
  clientEmail: string,
  privateKey: string,
): Promise<string | null> {
  const now = Math.floor(Date.now() / 1000);
  const jwtHeader = base64UrlEncode(
    new TextEncoder().encode(JSON.stringify({ alg: "RS256", typ: "JWT" })),
  );

  const jwtPayload = base64UrlEncode(
    new TextEncoder().encode(
      JSON.stringify({
        iss: clientEmail,
        scope: FCM_SCOPE,
        aud: OAUTH_URL,
        exp: now + 3600,
        iat: now,
      }),
    ),
  );

  const signatureInput = `${jwtHeader}.${jwtPayload}`;
  const signature = await signRsaSha256(privateKey, signatureInput);
  const assertion = `${signatureInput}.${signature}`;

  const response = await fetch(OAUTH_URL, {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: new URLSearchParams({
      grant_type: "urn:ietf:params:oauth:grant-type:jwt-bearer",
      assertion,
    }),
  });

  if (!response.ok) {
    console.error("OAuth2 token exchange failed", await response.text());
    return null;
  }

  const data = await response.json();
  return data.access_token as string;
}

function buildFcmMessage(
  deviceToken: string,
  title: string,
  body: string,
  data: Record<string, string>,
  platform: string,
) {
  const message: Record<string, unknown> = {
    token: deviceToken,
    notification: { title, body },
    data,
  };

  if (platform === "web") {
    message.webpush = {
      notification: { title, body },
      fcm_options: { link: data.link ?? "/" },
    };
  } else if (platform === "ios") {
    message.apns = {
      payload: { aps: { sound: "default", badge: 1, alert: { title, body } } },
    };
  } else {
    message.android = {
      notification: { title, body, sound: "default", channel_id: data.type ?? "general" },
    };
  }

  return { message };
}

async function sendFcmMessage(
  accessToken: string,
  deviceToken: string,
  title: string,
  body: string,
  data: Record<string, string>,
  platform: string,
): Promise<boolean> {
  const payload = buildFcmMessage(deviceToken, title, body, data, platform);

  const response = await fetch(FCM_URL, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      Authorization: `Bearer ${accessToken}`,
    },
    body: JSON.stringify(payload),
  });

  if (!response.ok) {
    const errorBody = await response.text();
    console.error(
      `FCM send failed for token ${deviceToken}: ${response.status} ${errorBody}`,
    );
    return false;
  }

  return true;
}

Deno.serve(async (req) => {
  if (req.method !== "POST") {
    return json({ error: "Method not allowed" }, { status: 405 });
  }

  if (!serviceAccountRaw) {
    return json(
      { error: "FCM_SERVICE_ACCOUNT not configured" },
      { status: 500 },
    );
  }

  let body: SendPushRequest;
  try {
    body = await req.json();
  } catch {
    return badRequest("Invalid JSON body");
  }

  if (!body.user_ids?.length || !body.title || !body.body || !body.type) {
    return badRequest("user_ids, title, body, and type are required");
  }

  const sa = parseServiceAccount(serviceAccountRaw);
  if (!sa) {
    return json(
      { error: "Invalid FCM_SERVICE_ACCOUNT format" },
      { status: 500 },
    );
  }

  const accessToken = await getAccessToken(sa.clientEmail, sa.privateKey);
  if (!accessToken) {
    return json(
      { error: "Failed to obtain OAuth2 access token" },
      { status: 500 },
    );
  }

  const { data: tokens, error: dbError } = await supabase
    .from("device_tokens")
    .select("id, user_id, token, platform")
    .in("user_id", body.user_ids)
    .eq("is_active", true);

  if (dbError) {
    return json(
      { error: "DB_QUERY_FAILED", message: dbError.message },
      { status: 500 },
    );
  }

  if (!tokens || tokens.length === 0) {
    return json({ success: true, sent: 0, failed: 0 });
  }

  const data = {
    ...(body.data ?? {}),
    type: body.type,
    title: body.title,
    body: body.body,
  };

  const failedTokenIds: string[] = [];

  const results = await Promise.allSettled(
    (tokens as DeviceTokenRow[]).map(async (t) => {
      const ok = await sendFcmMessage(
        accessToken,
        t.token,
        body.title,
        body.body,
        data,
        t.platform,
      );
      if (!ok) failedTokenIds.push(t.id);
    }),
  );

  let rejectCount = 0;
  for (const r of results) {
    if (r.status === "rejected") {
      rejectCount++;
      console.error("Unexpected error sending push:", r.reason);
    }
  }

  if (failedTokenIds.length > 0) {
    await supabase
      .from("device_tokens")
      .update({ is_active: false, updated_at: new Date().toISOString() })
      .in("id", failedTokenIds);
  }

  return json({
    success: true,
    sent: tokens.length - failedTokenIds.length - rejectCount,
    failed: failedTokenIds.length + rejectCount,
    deactivated: failedTokenIds.length,
  });
});
