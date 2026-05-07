import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createHmac, timingSafeEqual } from "node:crypto";
import { supabaseAdmin } from "../_shared/supabase.ts";
import { badRequest, json } from "../_shared/http.ts";

function verifySignature(
  rawBody: string,
  signature: string | null,
  secret: string | undefined,
): boolean {
  if (!secret) return true;
  if (!signature) return false;

  const expected = createHmac("sha256", secret).update(rawBody).digest("hex");
  const a = new TextEncoder().encode(expected);
  const b = new TextEncoder().encode(signature);

  if (a.length !== b.length) return false;
  return timingSafeEqual(a, b);
}

function mapOrderStatus(eventType: string): string | null {
  switch (eventType) {
    case "payment.approved":
      return "confirmed";
    case "payment.rejected":
    case "payment.cancelled":
      return "cancelled";
    default:
      return null;
  }
}

function mapPaymentStatus(eventType: string): string | null {
  switch (eventType) {
    case "payment.approved":
      return "approved";
    case "payment.rejected":
      return "rejected";
    case "payment.cancelled":
      return "cancelled";
    case "payment.refunded":
      return "refunded";
    default:
      return null;
  }
}

Deno.serve(async (req) => {
  if (req.method !== "POST") {
    return json({ error: "Method not allowed" }, { status: 405 });
  }

  const rawBody = await req.text();
  const secret = Deno.env.get("PTP_WEBHOOK_SECRET");
  const signature = req.headers.get("x-webhook-signature");

  if (!verifySignature(rawBody, signature, secret)) {
    return json({ error: "Invalid signature" }, { status: 401 });
  }

  let payload: {
    event_type?: string;
    gateway_event_id?: string;
    payment_intent_id?: string;
    order_id?: string;
    gateway_id?: string;
  };

  try {
    payload = JSON.parse(rawBody);
  } catch {
    return badRequest("Invalid JSON body");
  }

  if (!payload.event_type || !payload.payment_intent_id || !payload.order_id) {
    return badRequest("event_type, payment_intent_id and order_id are required");
  }

  if (payload.gateway_event_id) {
    const { data: existing } = await supabaseAdmin
      .from("payment_events")
      .select("id")
      .eq("gateway_event_id", payload.gateway_event_id)
      .limit(1)
      .maybeSingle();

    if (existing) {
      return json({ ok: true, duplicate: true });
    }
  }

  const paymentStatus = mapPaymentStatus(payload.event_type);
  const orderStatus = mapOrderStatus(payload.event_type);

  const { error: insertEventError } = await supabaseAdmin
    .from("payment_events")
    .insert({
      payment_intent_id: payload.payment_intent_id,
      event_type: payload.event_type,
      gateway_event_id: payload.gateway_event_id ?? null,
      payload,
      processed: false,
    });

  if (insertEventError) {
    return json(
      { error: "PAYMENT_EVENT_INSERT_FAILED", message: insertEventError.message },
      { status: 500 },
    );
  }

  if (paymentStatus) {
    const { error } = await supabaseAdmin
      .from("payment_intents")
      .update({
        status: paymentStatus,
        gateway_id: payload.gateway_id ?? null,
        gateway_response: payload,
      })
      .eq("id", payload.payment_intent_id);

    if (error) {
      return json(
        { error: "PAYMENT_INTENT_UPDATE_FAILED", message: error.message },
        { status: 500 },
      );
    }
  }

  if (orderStatus) {
    const { error } = await supabaseAdmin
      .from("orders")
      .update({ status: orderStatus })
      .eq("id", payload.order_id);

    if (error) {
      return json(
        { error: "ORDER_UPDATE_FAILED", message: error.message },
        { status: 500 },
      );
    }
  }

  return json({ ok: true });
});
