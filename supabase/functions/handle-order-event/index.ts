import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "npm:@supabase/supabase-js@2";
function json(data: unknown, init: ResponseInit = {}): Response {
  return new Response(JSON.stringify(data), {
    ...init,
    headers: { "Content-Type": "application/json", ...(init.headers ?? {}) },
  });
}

function badRequest(message: string, details?: unknown): Response {
  return json({ error: message, details }, { status: 400 });
}

const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

const supabase = createClient(supabaseUrl, serviceRoleKey, {
  auth: { persistSession: false, autoRefreshToken: false },
});

interface OrderEventWebhook {
  type: "INSERT";
  table: string;
  schema: string;
  record: {
    id: string;
    order_id: string;
    status: string;
    previous_status: string | null;
    changed_by: string | null;
    created_at: string;
  };
}

const STATUS_LABELS: Record<string, { es: string; en: string }> = {
  pending: { es: "Pendiente", en: "Pending" },
  confirmed: { es: "Confirmado", en: "Confirmed" },
  ready_for_pickup: { es: "Listo para recoger", en: "Ready for pickup" },
  picked_up: { es: "Recogido", en: "Picked up" },
  completed: { es: "Completado", en: "Completed" },
  cancelled: { es: "Cancelado", en: "Cancelled" },
  expired: { es: "Expirado", en: "Expired" },
};

const STATUS_MESSAGES: Record<string, { consumer: string; business: string }> = {
  pending: {
    consumer: "Pedido recibido. Estamos procesando tu reserva.",
    business: "Nuevo pedido recibido. Revisa los detalles.",
  },
  confirmed: {
    consumer: "Tu pedido ha sido confirmado. Prepara tu código de recogida.",
    business: "Nuevo pedido confirmado. Prepara el pedido.",
  },
  ready_for_pickup: {
    consumer: "Tu pedido está listo para recoger. ¡No esperes demasiado!",
    business: "El pedido está marcado como listo para recoger.",
  },
  picked_up: {
    consumer: "Gracias por recoger tu pedido. ¡Buen provecho!",
    business: "El cliente ha recogido su pedido.",
  },
  completed: {
    consumer: "Pedido completado. Cuéntanos cómo fue tu experiencia.",
    business: "Pedido completado exitosamente.",
  },
  cancelled: {
    consumer: "Tu pedido ha sido cancelado.",
    business: "El pedido ha sido cancelado.",
  },
  expired: {
    consumer: "El tiempo para recoger tu pedido ha expirado.",
    business: "El pedido ha expirado por falta de recogida.",
  },
};

async function sendPush(
  userIds: string[],
  title: string,
  body: string,
  data: Record<string, string>,
) {
  const { error } = await supabase.functions.invoke("send-push-notification", {
    body: { user_ids: userIds, title, body, data, type: "order" },
  });

  if (error) {
    console.error("Failed to invoke send-push-notification:", error.message);
  }
}

Deno.serve(async (req) => {
  if (req.method !== "POST") {
    return json({ error: "Method not allowed" }, { status: 405 });
  }

  let webhook: OrderEventWebhook;
  try {
    webhook = await req.json();
  } catch {
    return badRequest("Invalid JSON body");
  }

  if (webhook.type !== "INSERT") {
    return json({ success: true, skipped: true, reason: "Not an INSERT" });
  }

  const event = webhook.record;

  // Fetch the order details
  const { data: order, error: orderError } = await supabase
    .from("orders")
    .select("id, user_id, business_id, order_number, status")
    .eq("id", event.order_id)
    .single();

  if (orderError || !order) {
    console.error("Order not found:", event.order_id, orderError?.message);
    return json(
      { error: "ORDER_NOT_FOUND", message: orderError?.message },
      { status: 404 },
    );
  }

  // Fetch the business name
  const { data: business } = await supabase
    .from("businesses")
    .select("name")
    .eq("id", order.business_id)
    .single();

  const businessName = business?.name ?? "Negocio";
  const statusLabel = STATUS_LABELS[event.status]?.es ?? event.status;
  const messages = STATUS_MESSAGES[event.status];

  // Build notification data with navigation info
  const notificationData: Record<string, string> = {
    type: "order",
    order_id: order.id,
    order_number: order.order_number,
    status: event.status,
    link: "/orders/${order.id}",
  };

  // Notify the consumer
  if (messages) {
    await sendPush(
      [order.user_id],
      "${businessName} — ${statusLabel}",
      messages.consumer,
      notificationData,
    );
  } else {
    await sendPush(
      [order.user_id],
      "${businessName} — ${statusLabel}",
      "Tu pedido ha cambiado de estado.",
      notificationData,
    );
  }

  // Notify the business for relevant statuses
  if (event.status === "pending" || event.status === "confirmed" || event.status === "cancelled" || event.status === "expired") {
    const { data: businessOwner } = await supabase
      .from("businesses")
      .select("owner_id")
      .eq("id", order.business_id)
      .single();

    if (businessOwner) {
      const businessNotificationData: Record<string, string> = {
        type: "order",
        order_id: order.id,
        order_number: order.order_number,
        status: event.status,
        role: "business",
        link: "/business/orders/${order.id}",
      };

      const businessMessage = messages?.business ??
        "Un pedido ha cambiado de estado.";

      await sendPush(
        [businessOwner.owner_id],
        "Pedido #${order.order_number} — ${statusLabel}",
        businessMessage,
        businessNotificationData,
      );
    }
  }

  return json({ success: true });
});
