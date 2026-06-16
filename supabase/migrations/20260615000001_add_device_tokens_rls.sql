-- Migration: Add RLS policies for device_tokens
-- The table had RLS enabled but no explicit policies, which means
-- all operations were blocked. This allows users to manage their
-- own device tokens for push notifications.

-- Allow authenticated users to insert their own device tokens
create policy "Users can insert their own device tokens"
  on public.device_tokens for insert
  to authenticated
  with check (auth.uid() = user_id);

-- Allow authenticated users to read their own device tokens
create policy "Users can read their own device tokens"
  on public.device_tokens for select
  to authenticated
  using (auth.uid() = user_id);

-- Allow authenticated users to update their own device tokens
create policy "Users can update their own device tokens"
  on public.device_tokens for update
  to authenticated
  using (auth.uid() = user_id);

-- Allow authenticated users to delete their own device tokens
create policy "Users can delete their own device tokens"
  on public.device_tokens for delete
  to authenticated
  using (auth.uid() = user_id);

-- Service role bypasses RLS (needed for edge functions)
-- This is the default behavior for the service_role key.
