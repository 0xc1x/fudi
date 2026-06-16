-- Create dedicated business notification preferences table

create table public.business_notification_preferences (
  business_id uuid primary key references public.businesses(id),
  -- Channels
  push_enabled boolean not null default true,
  email_enabled boolean not null default true,
  sms_enabled boolean not null default false,
  whatsapp_enabled boolean not null default false,
  -- Event types
  new_orders_enabled boolean not null default true,
  pickup_ready_enabled boolean not null default true,
  reviews_enabled boolean not null default true,
  low_stock_enabled boolean not null default false,
  daily_summary_enabled boolean not null default true,
  -- Quiet hours
  quiet_hours_from time null,
  quiet_hours_to time null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- Trigger to auto-create a row when a business is inserted
create or replace function public.create_business_notification_preferences()
returns trigger
language plpgsql
security definer
set search_path to ''
as $function$
begin
  insert into public.business_notification_preferences (business_id)
  values (new.id)
  on conflict (business_id) do nothing;
  return new;
end;
$function$;

create trigger trg_create_business_notification_preferences
  after insert on public.businesses
  for each row
  execute function public.create_business_notification_preferences();

-- Enable RLS
alter table public.business_notification_preferences enable row level security;

-- RLS: business owners can manage their own preferences
create policy "Business owners view own notification preferences"
  on public.business_notification_preferences
  for select
  using (
    business_id in (
      select id from public.businesses where owner_id = auth.uid()
    )
  );

create policy "Business owners insert own notification preferences"
  on public.business_notification_preferences
  for insert
  with check (
    business_id in (
      select id from public.businesses where owner_id = auth.uid()
    )
  );

create policy "Business owners update own notification preferences"
  on public.business_notification_preferences
  for update
  using (
    business_id in (
      select id from public.businesses where owner_id = auth.uid()
    )
  );

-- Service role bypass (for edge functions)
create policy "Service role full access"
  on public.business_notification_preferences
  for all
  to service_role
  using (true)
  with check (true);

-- Index
create index idx_business_notif_prefs_business on public.business_notification_preferences (business_id);
