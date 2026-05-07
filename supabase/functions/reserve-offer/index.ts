import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { supabaseAdmin } from "../_shared/supabase.ts";
import { badRequest, json } from "../_shared/http.ts";

Deno.serve(async (req) => {
  if (req.method !== "POST") {
    return json({ error: "Method not allowed" }, { status: 405 });
  }

  let body: { user_id?: string; offer_id?: string; coupon_id?: string | null };

  try {
    body = await req.json();
  } catch {
    return badRequest("Invalid JSON body");
  }

  if (!body.user_id || !body.offer_id) {
    return badRequest("user_id and offer_id are required");
  }

  const { data, error } = await supabaseAdmin.rpc("reserve_offer", {
    p_user_id: body.user_id,
    p_offer_id: body.offer_id,
    p_coupon_id: body.coupon_id ?? null,
  });

  if (error) {
    return json(
      {
        success: false,
        error: "RESERVE_RPC_FAILED",
        message: error.message,
      },
      { status: 500 },
    );
  }

  return json(data);
});
