-- Migration: Add cancel_order RPC
-- Created at: 2026-05-18

create or replace function public.cancel_order(p_user_id uuid, p_order_id uuid)
returns jsonb
language plpgsql
security definer
set search_path to ''
as $function$
DECLARE
  v_order RECORD;
BEGIN
  -- Get order and lock it
  SELECT * INTO v_order
  FROM public.orders
  WHERE id = p_order_id AND user_id = p_user_id
  FOR UPDATE;

  IF NOT FOUND THEN
    RETURN jsonb_build_object('success', false, 'error', 'ORDER_NOT_FOUND', 'message', 'Pedido no encontrado');
  END IF;

  IF v_order.status NOT IN ('pending', 'confirmed', 'ready_for_pickup') THEN
    RETURN jsonb_build_object('success', false, 'error', 'INVALID_STATUS', 'message', 'No se puede cancelar un pedido en estado ' || v_order.status);
  END IF;

  -- Revert stock
  UPDATE public.offers
  SET stock = stock + 1
  WHERE id = v_order.offer_id;

  -- Update order status
  UPDATE public.orders
  SET status = 'cancelled',
      updated_at = now()
  WHERE id = p_order_id;

  -- Log event
  INSERT INTO public.order_events (order_id, status, previous_status, changed_by, reason)
  VALUES (p_order_id, 'cancelled', v_order.status, p_user_id, 'Cancelado por el usuario');

  RETURN jsonb_build_object(
    'success', true,
    'order_id', p_order_id,
    'status', 'cancelled'
  );
END;
$function$;

-- Grant execute to authenticated users
grant execute on function public.cancel_order(uuid, uuid) to authenticated;
