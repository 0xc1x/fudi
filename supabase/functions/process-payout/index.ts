import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { supabaseAdmin } from "../_shared/supabase.ts";
import { badRequest, json } from "../_shared/http.ts";

Deno.serve(async (req) => {
  if (req.method !== "POST") {
    return json({ error: "Method not allowed" }, { status: 405 });
  }

  const body = await req.json().catch(() => ({}));
  const periodStart = body.period_start as string | undefined;
  const periodEnd = body.period_end as string | undefined;
  const feePct = Number(Deno.env.get("PLATFORM_FEE_PCT") ?? "10");

  if (!periodStart || !periodEnd) {
    return badRequest("period_start and period_end are required");
  }

  const { data: orders, error } = await supabaseAdmin
    .from("orders")
    .select("business_id, price, updated_at")
    .eq("status", "completed")
    .gte("updated_at", `${periodStart}T00:00:00Z`)
    .lte("updated_at", `${periodEnd}T23:59:59Z`);

  if (error) {
    return json({ error: "ORDERS_QUERY_FAILED", message: error.message }, { status: 500 });
  }

  const grouped = new Map<string, number>();
  for (const order of orders ?? []) {
    const total = grouped.get(order.business_id) ?? 0;
    grouped.set(order.business_id, total + Number(order.price));
  }

  const inserts = [...grouped.entries()].map(([businessId, grossAmount]) => {
    const platformFee = Number(((grossAmount * feePct) / 100).toFixed(2));
    const netAmount = Number((grossAmount - platformFee).toFixed(2));
    return {
      business_id: businessId,
      period_start: periodStart,
      period_end: periodEnd,
      gross_amount: grossAmount,
      platform_fee: platformFee,
      net_amount: netAmount,
      status: "pending",
    };
  });

  if (inserts.length === 0) {
    return json({ ok: true, created: 0, message: "No completed orders in range" });
  }

  const { data: payouts, error: insertError } = await supabaseAdmin
    .from("payouts")
    .insert(inserts)
    .select("id, business_id, gross_amount, platform_fee, net_amount, status");

  if (insertError) {
    return json({ error: "PAYOUT_INSERT_FAILED", message: insertError.message }, { status: 500 });
  }

  return json({ ok: true, created: payouts?.length ?? 0, payouts });
});
