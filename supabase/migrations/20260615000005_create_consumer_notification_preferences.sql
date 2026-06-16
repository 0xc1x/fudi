-- Create dedicated consumer notification preferences table
-- Separates notification settings from user_preferences (UI settings)

create table public.consumer_notification_preferences (
  user_id uuid primary key references public.profiles(id),
  -- Channels
  push_enabled boolean not null default true,
  email_enabled boolean not null default true,
  sms_enabled boolean not null default false,
  whatsapp_enabled boolean not null default false,
  -- Alert types
  favorite_alerts_enabled boolean not null default true,
  pickup_reminders_enabled boolean not null default true,
  last_minute_deals_enabled boolean not null default false,
  weekly_summary_enabled boolean not null default true,
  -- Quiet hours
  quiet_hours_from time null,
  quiet_hours_to time null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- Migrate existing data from user_preferences
insert into public.consumer_notification_preferences (user_id, push_enabled, email_enabled)
select user_id, push_notifications_enabled, email_notifications_enabled
from public.user_preferences
on conflict (user_id) do nothing;

-- Drop old columns from user_preferences
alter table public.user_preferences drop column push_notifications_enabled;
alter table public.user_preferences drop column email_notifications_enabled;

-- Extend create_user_preferences trigger to also create notification preferences
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

-- Enable RLS
alter table public.consumer_notification_preferences enable row level security;

-- RLS: users can only see their own preferences
create policy "Users can view own notification preferences"
  on public.consumer_notification_preferences
  for select
  using (auth.uid() = user_id);

create policy "Users can insert own notification preferences"
  on public.consumer_notification_preferences
  for insert
  with check (auth.uid() = user_id);

create policy "Users can update own notification preferences"
  on public.consumer_notification_preferences
  for update
  using (auth.uid() = user_id);

-- Service role bypass (for edge functions)
create policy "Service role full access"
  on public.consumer_notification_preferences
  for all
  to service_role
  using (true)
  with check (true);

-- Index for edge function lookups by user_id (primary key covers it, but explicit for clarity)
create index idx_consumer_notif_prefs_user on public.consumer_notification_preferences (user_id);
