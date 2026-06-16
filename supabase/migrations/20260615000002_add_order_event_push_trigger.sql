-- Migration: Add trigger to call handle-order-event on new order_events
-- Uses pg_net to asynchronously invoke the edge function.
-- pg_net was enabled in a separate step.

create or replace function public.handle_order_event_push()
returns trigger
language plpgsql
security definer
set search_path to ''
as $$
declare
  edge_url text := 'https://sxqopofoynsqkztozlix.supabase.co/functions/v1';
  anon_key text := 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InN4cW9wb2ZveW5zcWt6dG96bGl4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzYzODMwMzQsImV4cCI6MjA5MTk1OTAzNH0.iDHR8RrBGSD_EbfzwLJzAfhWQonilETYJJuYB_a6R7g';
begin
  perform net.http_post(
    url := edge_url || '/notify-order-event',
    headers := jsonb_build_object(
      'Content-Type', 'application/json',
      'apikey', anon_key,
      'Authorization', 'Bearer ' || anon_key
    ),
    body := jsonb_build_object(
      'type', 'INSERT',
      'table', 'order_events',
      'schema', 'public',
      'record', row_to_json(new)
    ),
    timeout_milliseconds := 10000
  );
  return new;
end;
$$;

create trigger trg_order_event_push
  after insert on public.order_events
  for each row
  execute function public.handle_order_event_push();
