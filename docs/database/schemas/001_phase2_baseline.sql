-- Fudi Phase 2 baseline schema snapshot
-- Source: remote Supabase project sxqopofoynsqkztozlix
-- Captured on: 2026-05-07
-- Purpose: establish a repo-side baseline after the schema was created remotely first.
-- IMPORTANT: this is a baseline snapshot for traceability. It is NOT the original granular migration history.

create extension if not exists pgcrypto;

create type public.app_role as enum ('user', 'business', 'admin');
create type public.business_type as enum ('restaurant', 'bakery', 'cafe', 'grocery', 'other');
create type public.coupon_type as enum ('percentage', 'fixed');
create type public.day_of_week as enum ('monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday');
create type public.order_status as enum ('pending', 'confirmed', 'ready_for_pickup', 'picked_up', 'completed', 'cancelled', 'expired');
create type public.payment_gateway as enum ('place_to_pay', 'stripe');
create type public.payment_intent_status as enum ('pending', 'processing', 'approved', 'rejected', 'cancelled', 'refunded');
create type public.payout_status as enum ('pending', 'processing', 'paid', 'failed');

create table public.profiles (
  id uuid primary key references auth.users(id),
  email text not null,
  full_name text,
  avatar_url text,
  phone text,
  role public.app_role not null default 'user',
  city text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.businesses (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references public.profiles(id),
  name text not null,
  type public.business_type not null default 'restaurant',
  slug text not null unique,
  image text,
  cover_image text,
  rating numeric default 0,
  review_count integer default 0,
  description text,
  address text not null,
  phone text,
  email text,
  website text,
  latitude numeric,
  longitude numeric,
  commission_rate numeric default 0.1000,
  balance numeric default 0.00,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.business_locations (
  id uuid primary key default gen_random_uuid(),
  business_id uuid not null references public.businesses(id),
  name text not null,
  address text not null,
  phone text,
  latitude numeric not null,
  longitude numeric not null,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.business_hours (
  id uuid primary key default gen_random_uuid(),
  business_id uuid not null references public.businesses(id),
  day public.day_of_week not null,
  open_time time not null,
  close_time time not null,
  is_closed boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (business_id, day)
);

create table public.offers (
  id uuid primary key default gen_random_uuid(),
  business_id uuid not null references public.businesses(id),
  title text not null,
  description text,
  image text,
  category text,
  original_price numeric not null check (original_price > 0),
  discounted_price numeric not null check (discounted_price > 0),
  discount_percentage numeric generated always as (round((((original_price - discounted_price) / original_price) * 100::numeric), 2)) stored,
  rating numeric default 0,
  stock integer not null default 1 check (stock >= 0),
  initial_stock integer not null default 1 check (initial_stock >= 0),
  pickup_start timestamptz not null,
  pickup_end timestamptz not null,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.coupons (
  id uuid primary key default gen_random_uuid(),
  business_id uuid not null references public.businesses(id),
  code text not null,
  name text not null,
  type public.coupon_type not null,
  value numeric not null check (value > 0),
  min_order_amount numeric default 0,
  max_uses integer check (max_uses is null or max_uses > 0),
  used_count integer not null default 0,
  is_active boolean not null default true,
  expires_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (business_id, code)
);

create table public.orders (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id),
  offer_id uuid not null references public.offers(id),
  business_id uuid not null references public.businesses(id),
  order_number text not null unique,
  status public.order_status not null default 'pending',
  price numeric not null check (price > 0),
  original_price numeric not null check (original_price > 0),
  pickup_code text not null,
  pickup_time timestamptz,
  coupon_id uuid references public.coupons(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.order_events (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders(id),
  status public.order_status not null,
  previous_status public.order_status,
  changed_by uuid references public.profiles(id),
  reason text,
  metadata jsonb default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create table public.favorites (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id),
  offer_id uuid not null references public.offers(id),
  created_at timestamptz not null default now(),
  unique (user_id, offer_id)
);

create table public.reviews (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id),
  business_id uuid not null references public.businesses(id),
  order_id uuid references public.orders(id),
  rating integer not null check (rating >= 1 and rating <= 5),
  comment text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (user_id, order_id)
);

create table public.payment_intents (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders(id),
  gateway public.payment_gateway not null default 'place_to_pay',
  gateway_id text,
  amount numeric not null check (amount > 0),
  currency text not null default 'COP',
  status public.payment_intent_status not null default 'pending',
  gateway_response jsonb default '{}'::jsonb,
  idempotency_key uuid not null default gen_random_uuid(),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.payment_events (
  id uuid primary key default gen_random_uuid(),
  payment_intent_id uuid not null references public.payment_intents(id),
  event_type text not null,
  gateway_event_id text,
  payload jsonb not null default '{}'::jsonb,
  processed boolean not null default false,
  created_at timestamptz not null default now()
);

create table public.payouts (
  id uuid primary key default gen_random_uuid(),
  business_id uuid not null references public.businesses(id),
  period_start date not null,
  period_end date not null,
  gross_amount numeric not null check (gross_amount >= 0),
  platform_fee numeric not null check (platform_fee >= 0),
  net_amount numeric not null check (net_amount >= 0),
  status public.payout_status not null default 'pending',
  gateway_payout_id text,
  paid_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.user_consents (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id),
  consent_type text not null,
  granted boolean not null default false,
  granted_at timestamptz,
  revoked_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (user_id, consent_type)
);

create table public.user_preferences (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null unique references public.profiles(id),
  notification_radius_km integer default 5,
  favorite_categories text[] default '{}'::text[],
  language text default 'es',
  dark_mode boolean default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.consumer_notification_preferences (
  user_id uuid primary key references public.profiles(id),
  push_enabled boolean not null default true,
  email_enabled boolean not null default true,
  sms_enabled boolean not null default false,
  whatsapp_enabled boolean not null default false,
  favorite_alerts_enabled boolean not null default true,
  pickup_reminders_enabled boolean not null default true,
  last_minute_deals_enabled boolean not null default false,
  weekly_summary_enabled boolean not null default true,
  quiet_hours_from time null,
  quiet_hours_to time null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.business_notification_preferences (
  business_id uuid primary key references public.businesses(id),
  push_enabled boolean not null default true,
  email_enabled boolean not null default true,
  sms_enabled boolean not null default false,
  whatsapp_enabled boolean not null default false,
  new_orders_enabled boolean not null default true,
  pickup_ready_enabled boolean not null default true,
  reviews_enabled boolean not null default true,
  low_stock_enabled boolean not null default false,
  daily_summary_enabled boolean not null default true,
  quiet_hours_from time null,
  quiet_hours_to time null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.saved_addresses (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id),
  label text not null,
  address text not null,
  latitude numeric not null,
  longitude numeric not null,
  is_default boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.device_tokens (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id),
  token text not null unique,
  platform text not null check (platform = any (array['ios'::text, 'android'::text, 'web'::text])),
  device_info jsonb default '{}'::jsonb,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index idx_profiles_role on public.profiles (role);
create index idx_businesses_owner on public.businesses (owner_id);
create index idx_businesses_slug on public.businesses (slug);
create index idx_businesses_active on public.businesses (is_active) where is_active = true;
create index idx_businesses_type on public.businesses (type) where is_active = true;
create index idx_businesses_location on public.businesses (latitude, longitude) where is_active = true;
create index idx_business_locations_business on public.business_locations (business_id);
create index idx_business_locations_active on public.business_locations (business_id) where is_active = true;
create index idx_business_hours_business on public.business_hours (business_id);
create index idx_offers_business on public.offers (business_id);
create index idx_offers_active on public.offers (is_active) where is_active = true;
create index idx_offers_category on public.offers (category) where is_active = true;
create index idx_offers_price on public.offers (discounted_price) where is_active = true;
create index idx_offers_pickup_window on public.offers (pickup_start, pickup_end) where is_active = true;
create index idx_offers_stock on public.offers (stock) where is_active = true and stock > 0;
create index idx_coupons_business on public.coupons (business_id);
create index idx_coupons_active on public.coupons (is_active) where is_active = true;
create index idx_coupons_code on public.coupons (code) where is_active = true;
create index idx_orders_user on public.orders (user_id);
create index idx_orders_business on public.orders (business_id);
create index idx_orders_offer on public.orders (offer_id);
create index idx_orders_status on public.orders (status);
create index idx_orders_number on public.orders (order_number);
create index idx_orders_created on public.orders (created_at desc);
create index idx_orders_pickup_code on public.orders (pickup_code) where status = any (array['confirmed'::public.order_status, 'ready_for_pickup'::public.order_status]);
create index idx_order_events_order on public.order_events (order_id);
create index idx_order_events_created on public.order_events (created_at desc);
create index idx_favorites_user on public.favorites (user_id);
create index idx_favorites_offer on public.favorites (offer_id);
create index idx_reviews_user on public.reviews (user_id);
create index idx_reviews_business on public.reviews (business_id);
create index idx_reviews_rating on public.reviews (rating);
create index idx_payment_intents_order on public.payment_intents (order_id);
create index idx_payment_intents_status on public.payment_intents (status);
create index idx_payment_intents_idempotency on public.payment_intents (idempotency_key);
create index idx_payment_intents_gateway_id on public.payment_intents (gateway_id) where gateway_id is not null;
create index idx_payment_events_intent on public.payment_events (payment_intent_id);
create index idx_payment_events_type on public.payment_events (event_type);
create index idx_payment_events_processed on public.payment_events (processed) where processed = false;
create index idx_payment_events_gateway_id on public.payment_events (gateway_event_id) where gateway_event_id is not null;
create index idx_payouts_business on public.payouts (business_id);
create index idx_payouts_period on public.payouts (period_start, period_end);
create index idx_payouts_status on public.payouts (status);
create index idx_user_consents_user on public.user_consents (user_id);
create index idx_user_consents_type on public.user_consents (consent_type);
create index idx_user_preferences_user on public.user_preferences (user_id);
create index idx_saved_addresses_user on public.saved_addresses (user_id);
create index idx_device_tokens_user on public.device_tokens (user_id);
create index idx_device_tokens_active on public.device_tokens (is_active) where is_active = true;

create or replace function public.check_offer_expiry()
returns trigger
language plpgsql
set search_path to ''
as $function$
BEGIN
  IF NEW.stock = 0 AND OLD.stock > 0 THEN
    NEW.is_active := false;
  END IF;

  IF NEW.stock > 0 AND OLD.stock = 0 AND NEW.is_active = false THEN
    IF NEW.pickup_end > now() THEN
      NEW.is_active := true;
    END IF;
  END IF;

  RETURN NEW;
END;
$function$;

create or replace function public.create_default_consents()
returns trigger
language plpgsql
security definer
set search_path to ''
as $function$
BEGIN
  INSERT INTO public.user_consents (user_id, consent_type, granted)
  VALUES
    (NEW.id, 'analytics', false),
    (NEW.id, 'marketing', false),
    (NEW.id, 'notifications', true)
  ON CONFLICT (user_id, consent_type) DO NOTHING;
  RETURN NEW;
END;
$function$;

create or replace function public.create_user_preferences()
returns trigger
language plpgsql
security definer
set search_path to ''
as $function$
begin
  insert into public.user_preferences (user_id)
  values (new.id)
  on conflict (user_id) do nothing;

  insert into public.consumer_notification_preferences (user_id)
  values (new.id)
  on conflict (user_id) do nothing;

  return new;
end;
$function$;

create or replace function public.generate_order_number()
returns text
language plpgsql
set search_path to ''
as $function$
DECLARE
  today TEXT := to_char(now(), 'YYYY-MMDD');
  prefix TEXT := 'FD-' || today || '-';
  next_seq INTEGER;
BEGIN
  SELECT COALESCE(MAX(CAST(SUBSTRING(order_number FROM LENGTH(prefix) + 1) AS INTEGER)), 0) + 1
    INTO next_seq
  FROM public.orders
  WHERE order_number LIKE prefix || '%';

  RETURN prefix || lpad(next_seq::text, 3, '0');
END;
$function$;

create or replace function public.generate_pickup_code()
returns text
language plpgsql
set search_path to ''
as $function$
DECLARE
  chars TEXT := 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
  result TEXT := '';
  i INTEGER;
BEGIN
  FOR i IN 1..6 LOOP
    result := result || substr(chars, floor(random() * length(chars) + 1)::integer, 1);
  END LOOP;
  RETURN result;
END;
$function$;

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path to ''
as $function$
BEGIN
  INSERT INTO public.profiles (id, email, full_name, avatar_url, phone, role)
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'full_name', ''),
    NEW.raw_user_meta_data->>'avatar_url',
    NEW.phone,
    COALESCE(NEW.raw_user_meta_data->>'role', 'user')::public.app_role
  );
  RETURN NEW;
END;
$function$;

create or replace function public.handle_updated_at()
returns trigger
language plpgsql
set search_path to ''
as $function$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$function$;

create or replace function public.on_order_status_change()
returns trigger
language plpgsql
set search_path to ''
as $function$
BEGIN
  IF OLD.status IS DISTINCT FROM NEW.status THEN
    INSERT INTO public.order_events (order_id, status, previous_status, changed_by)
    VALUES (NEW.id, NEW.status, OLD.status, auth.uid());
  END IF;
  RETURN NEW;
END;
$function$;

create or replace function public.reserve_offer(p_user_id uuid, p_offer_id uuid, p_coupon_id uuid default null::uuid)
returns jsonb
language plpgsql
security definer
set search_path to ''
as $function$
DECLARE
  v_offer RECORD;
  v_order_id UUID;
  v_order_number TEXT;
  v_pickup_code TEXT;
  v_price NUMERIC(10,2);
  v_original_price NUMERIC(10,2);
  v_coupon RECORD;
  v_discount NUMERIC(10,2) := 0;
BEGIN
  SELECT * INTO v_offer
  FROM public.offers
  WHERE id = p_offer_id AND is_active = true
  FOR UPDATE;

  IF NOT FOUND THEN
    RETURN jsonb_build_object('success', false, 'error', 'OFFER_NOT_FOUND', 'message', 'Oferta no encontrada o inactiva');
  END IF;

  IF v_offer.stock <= 0 THEN
    RETURN jsonb_build_object('success', false, 'error', 'OFFER_OUT_OF_STOCK', 'message', 'Oferta agotada');
  END IF;

  IF now() > v_offer.pickup_end THEN
    RETURN jsonb_build_object('success', false, 'error', 'OFFER_EXPIRED', 'message', 'Ventana de pickup cerrada');
  END IF;

  IF EXISTS (
    SELECT 1 FROM public.orders
    WHERE user_id = p_user_id
      AND offer_id = p_offer_id
      AND status IN ('pending', 'confirmed', 'ready_for_pickup')
  ) THEN
    RETURN jsonb_build_object('success', false, 'error', 'DUPLICATE_RESERVATION', 'message', 'Ya tienes una reserva activa para esta oferta');
  END IF;

  v_price := v_offer.discounted_price;
  v_original_price := v_offer.original_price;

  IF p_coupon_id IS NOT NULL THEN
    SELECT * INTO v_coupon
    FROM public.coupons
    WHERE id = p_coupon_id
      AND business_id = v_offer.business_id
      AND is_active = true
      AND (expires_at IS NULL OR expires_at > now())
    FOR UPDATE;

    IF FOUND THEN
      IF v_coupon.max_uses IS NOT NULL AND v_coupon.used_count >= v_coupon.max_uses THEN
        RETURN jsonb_build_object('success', false, 'error', 'COUPON_EXHAUSTED', 'message', 'Cupon agotado');
      END IF;

      IF v_coupon.min_order_amount > v_price THEN
        RETURN jsonb_build_object('success', false, 'error', 'COUPON_MIN_NOT_MET', 'message', 'Monto minimo no alcanzado para el cupon');
      END IF;

      IF v_coupon.type = 'percentage' THEN
        v_discount := LEAST(v_price * v_coupon.value / 100, v_price);
      ELSE
        v_discount := LEAST(v_coupon.value, v_price);
      END IF;

      v_price := GREATEST(v_price - v_discount, 0);

      UPDATE public.coupons
      SET used_count = used_count + 1
      WHERE id = p_coupon_id;
    END IF;
  END IF;

  UPDATE public.offers
  SET stock = stock - 1
  WHERE id = p_offer_id AND stock > 0;

  IF NOT FOUND THEN
    RETURN jsonb_build_object('success', false, 'error', 'OFFER_OUT_OF_STOCK', 'message', 'Oferta agotada (condicion de carrera)');
  END IF;

  v_order_number := public.generate_order_number();
  v_pickup_code := public.generate_pickup_code();

  INSERT INTO public.orders (
    user_id, offer_id, business_id, order_number,
    status, price, original_price, pickup_code, coupon_id
  ) VALUES (
    p_user_id, p_offer_id, v_offer.business_id, v_order_number,
    'pending', v_price, v_original_price, v_pickup_code, p_coupon_id
  )
  RETURNING id INTO v_order_id;

  INSERT INTO public.order_events (order_id, status, previous_status, changed_by, reason)
  VALUES (v_order_id, 'pending', NULL, p_user_id, 'Reserva creada');

  RETURN jsonb_build_object(
    'success', true,
    'order_id', v_order_id,
    'order_number', v_order_number,
    'pickup_code', v_pickup_code,
    'price', v_price,
    'original_price', v_original_price,
    'discount', v_discount,
    'status', 'pending'
  );
END;
$function$;

create or replace function public.rls_auto_enable()
returns event_trigger
language plpgsql
security definer
set search_path to 'pg_catalog'
as $function$
DECLARE
  cmd record;
BEGIN
  FOR cmd IN
    SELECT *
    FROM pg_event_trigger_ddl_commands()
    WHERE command_tag IN ('CREATE TABLE', 'CREATE TABLE AS', 'SELECT INTO')
      AND object_type IN ('table','partitioned table')
  LOOP
    IF cmd.schema_name IS NOT NULL
       AND cmd.schema_name IN ('public')
       AND cmd.schema_name NOT IN ('pg_catalog','information_schema')
       AND cmd.schema_name NOT LIKE 'pg_toast%'
       AND cmd.schema_name NOT LIKE 'pg_temp%' THEN
      BEGIN
        EXECUTE format('alter table if exists %s enable row level security', cmd.object_identity);
      EXCEPTION WHEN OTHERS THEN
        RAISE LOG 'rls_auto_enable: failed to enable RLS on %', cmd.object_identity;
      END;
    END IF;
  END LOOP;
END;
$function$;

create or replace function public.update_business_rating()
returns trigger
language plpgsql
set search_path to ''
as $function$
DECLARE
  v_business_id UUID;
BEGIN
  IF TG_OP = 'DELETE' THEN
    v_business_id := OLD.business_id;
  ELSE
    v_business_id := NEW.business_id;
  END IF;

  UPDATE public.businesses
  SET
    rating = (
      SELECT COALESCE(AVG(rating), 0)
      FROM public.reviews
      WHERE business_id = v_business_id
    ),
    review_count = (
      SELECT COUNT(*)
      FROM public.reviews
      WHERE business_id = v_business_id
    )
  WHERE id = v_business_id;

  RETURN COALESCE(NEW, OLD);
END;
$function$;

create trigger set_profiles_updated_at before update on public.profiles for each row execute function public.handle_updated_at();
create trigger set_businesses_updated_at before update on public.businesses for each row execute function public.handle_updated_at();
create trigger set_business_locations_updated_at before update on public.business_locations for each row execute function public.handle_updated_at();
create trigger set_business_hours_updated_at before update on public.business_hours for each row execute function public.handle_updated_at();
create trigger set_offers_updated_at before update on public.offers for each row execute function public.handle_updated_at();
create trigger on_offer_stock_change before update of stock on public.offers for each row when (old.stock is distinct from new.stock) execute function public.check_offer_expiry();
create trigger set_coupons_updated_at before update on public.coupons for each row execute function public.handle_updated_at();
create trigger set_orders_updated_at before update on public.orders for each row execute function public.handle_updated_at();
create trigger on_order_status_change after update of status on public.orders for each row when (old.status is distinct from new.status) execute function public.on_order_status_change();
create trigger set_reviews_updated_at before update on public.reviews for each row execute function public.handle_updated_at();
create trigger on_review_change after insert or delete or update on public.reviews for each row execute function public.update_business_rating();
create trigger set_payment_intents_updated_at before update on public.payment_intents for each row execute function public.handle_updated_at();
create trigger set_payouts_updated_at before update on public.payouts for each row execute function public.handle_updated_at();
create trigger on_profile_created after insert on public.profiles for each row execute function public.create_user_preferences();
create trigger on_profile_created_consents after insert on public.profiles for each row execute function public.create_default_consents();
create trigger set_user_consents_updated_at before update on public.user_consents for each row execute function public.handle_updated_at();
create trigger set_user_preferences_updated_at before update on public.user_preferences for each row execute function public.handle_updated_at();
create trigger set_saved_addresses_updated_at before update on public.saved_addresses for each row execute function public.handle_updated_at();
create trigger set_device_tokens_updated_at before update on public.device_tokens for each row execute function public.handle_updated_at();

alter table public.profiles enable row level security;
alter table public.businesses enable row level security;
alter table public.business_locations enable row level security;
alter table public.business_hours enable row level security;
alter table public.offers enable row level security;
alter table public.coupons enable row level security;
alter table public.orders enable row level security;
alter table public.order_events enable row level security;
alter table public.favorites enable row level security;
alter table public.reviews enable row level security;
alter table public.payment_intents enable row level security;
alter table public.payment_events enable row level security;
alter table public.payouts enable row level security;
alter table public.user_consents enable row level security;
alter table public.user_preferences enable row level security;
alter table public.saved_addresses enable row level security;
alter table public.device_tokens enable row level security;

-- Event trigger inferred from remote pg_event_trigger metadata.
create event trigger ensure_rls on ddl_command_end execute function public.rls_auto_enable();
