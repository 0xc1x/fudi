-- Migration: Setup push notification cron jobs
-- Requires pg_net and pg_cron extensions (enabled in previous migrations)

-- Schedule: run dispatch-nearby-offers every 2 hours
select cron.schedule(
  'dispatch-nearby-offers',
  '0 */2 * * *',
  $$
  select net.http_post(
    url:='https://sxqopofoynsqkztozlix.supabase.co/functions/v1/dispatch-nearby-offers',
    headers:='{"Content-Type": "application/json"}'::jsonb,
    timeout_milliseconds:=30000
  ) as request_id;
  $$
);

-- Weekly cleanup of old inactive device tokens (older than 90 days)
create or replace function public.cleanup_old_device_tokens()
returns void
language plpgsql
security definer
as $$
begin
  delete from public.device_tokens
  where is_active = false
    and updated_at < now() - interval '90 days';
end;
$$;

select cron.schedule(
  'cleanup-old-device-tokens',
  '0 3 * * 0',
  $$ select public.cleanup_old_device_tokens(); $$
);
