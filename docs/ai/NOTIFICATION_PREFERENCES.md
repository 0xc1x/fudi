# Notification Preferences — Refactor Plan

> Status: Draft for review
> Last updated: 2026-06-15

## Problem

Current notification preferences are fragmented across multiple models, repositories, and storage layers, with no server-side enforcement.

| Area | Issue |
|---|---|
| **Consumer** | `user_preferences` mixes UI settings (dark_mode, language) with notification toggles. 4 fields (`favoriteAlertsEnabled`, `pickupRemindersEnabled`, `lastMinuteDealsEnabled`, `weeklySummaryEnabled`) exist only in `SharedPreferences` — the server cannot read them. No SMS/WhatsApp support. |
| **Business** | `BusinessNotificationsScreen` has a full UI (event types, channels, quiet hours) but **zero persistence** — no domain model, no repository, no DB table. Save button shows a no-op SnackBar. |
| **Server** | `handle-order-event` and `dispatch-nearby-offers` do not check per-type notification preferences before dispatching. Quiet hours are not enforced anywhere. |

## Solution: one table per domain

Instead of adding more columns to `user_preferences`, create dedicated tables. Two tables rather than one because:

- **FK integrity**: each has a real foreign key to its own parent table (`profiles` / `businesses`)
- **No nullable columns**: every column is always relevant; no `null` cells for fields that don't apply
- **RLS differences**: consumer policy (`user_id = auth.uid()`) vs business policy (`business_id IN (SELECT id FROM businesses WHERE owner_id = auth.uid())`) are structurally different
- **Independent evolution**: consumer alert types and business event types change separately

```
user_preferences (existing)              → UI settings only
consumer_notification_preferences (new)  → channels + alert types + quiet hours
business_notification_preferences (new)  → channels + event types + quiet hours
```

---

## Phase 1: Schema, models, repositories, providers

### 1.1 Migration — `consumer_notification_preferences`

```sql
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

-- Extend the existing create_user_preferences() trigger to also insert into this table
```

**Data migration**: copy `push_notifications_enabled` and `email_notifications_enabled` from `user_preferences` to the new table.

**Drop** `push_notifications_enabled` and `email_notifications_enabled` from `user_preferences`.

### 1.2 Migration — `business_notification_preferences`

```sql
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

-- Trigger on businesses INSERT to auto-create a row
```

### 1.3 Domain models (Dart)

**New file: `lib/features/profile/domain/consumer_notification_preferences.dart`**

```dart
class ConsumerNotificationPreferences {
  final bool pushEnabled;
  final bool emailEnabled;
  final bool smsEnabled;
  final bool whatsappEnabled;
  final bool favoriteAlertsEnabled;
  final bool pickupRemindersEnabled;
  final bool lastMinuteDealsEnabled;
  final bool weeklySummaryEnabled;
  final String? quietHoursFrom;   // "HH:mm" format
  final String? quietHoursTo;     // "HH:mm" format

  // copyWith, static const defaults, static const empty
}
```

**New file: `lib/features/business/domain/business_notification_preferences.dart`**

Same pattern with event-type fields (`newOrdersEnabled`, `pickupReadyEnabled`, `reviewsEnabled`, `lowStockEnabled`, `dailySummaryEnabled`) instead of alert-type fields.

### 1.4 Repositories

```
lib/features/profile/domain/consumer_notification_repository.dart
lib/features/profile/data/supabase_consumer_notification_repository.dart

lib/features/business/domain/business_notification_repository.dart
lib/features/business/data/supabase_business_notification_repository.dart
```

Each with `getPreferences(id)` and `updatePreferences(prefs)`.

### 1.5 Providers

- `consumerNotificationPreferencesProvider` — `FutureProvider` in `profile_providers.dart`
- `businessNotificationPreferencesProvider` — `FutureProvider.family` by `businessId` in `business_providers.dart`
- `businessNotificationRepositoryProvider` — `Provider` in `business_providers.dart`

### 1.6 Clean up `ConsumerPreferences`

Remove these fields from `ConsumerPreferences`:
- `pushNotificationsEnabled`
- `emailNotificationsEnabled`
- `favoriteAlertsEnabled`
- `pickupRemindersEnabled`
- `lastMinuteDealsEnabled`
- `weeklySummaryEnabled`

`ConsumerPreferences` stays with: `notificationRadiusKm`, `language`, `darkMode`, `favoriteCategories`.

Also remove read/write of these fields from `SupabaseConsumerProfileRepository`.

---

## Phase 2: Functional UI

### 2.1 `BusinessNotificationsScreen` — Riverpod rewrite

- Read from `businessNotificationPreferencesProvider(businessId)`
- Auto-save on toggle change (no separate save button — each change persists immediately)
- SMS/WhatsApp toggles rendered but **disabled** with subtitle "Próximamente"
- Quiet hours persist `quiet_hours_from` / `quiet_hours_to`
- Remove local `_NotificationSetting` and `_NotificationChannel` classes; use domain models

### 2.2 `NotificationSettingsScreen` — refactor

- Read from `consumerNotificationPreferencesProvider`
- Channels: push / email enabled; sms / whatsapp disabled with "Próximamente"
- Alert types: all 4 persisted to new DB table (instead of local SharedPreferences)
- Auto-save on toggle change

### 2.3 `GeneralSettingsScreen` — no changes

---

## Phase 3: Server-side enforcement

### 3.1 `send-push-notification` Edge Function

- Accept optional `channel: 'push' | 'email' | 'sms' | 'whatsapp'` parameter
- When channel is specified, query the appropriate preferences table and filter recipients who have that channel disabled
- Prepare structure for email/SMS (log instead of send while those channels are not configured)
- Check quiet hours before sending

### 3.2 `handle-order-event` Edge Function

Before invoking `send-push-notification`:

1. If recipient is **business**: query `business_notification_preferences` for the business
   - Check specific event type is enabled (e.g., `new_orders_enabled`)
   - Check `push_enabled` is true
   - Check quiet hours
2. If recipient is **consumer**: query `consumer_notification_preferences`
   - Check `push_enabled` is true
   - Check quiet hours

### 3.3 `dispatch-nearby-offers` Edge Function

- Query `consumer_notification_preferences` alongside `user_preferences`
- Skip user if `last_minute_deals_enabled = false` (for offers near expiry)
- Skip user if `favorite_alerts_enabled = false` (for favorite-category offers)

### 3.4 Quiet hours

Rule: if `quiet_hours_from <= current_time < quiet_hours_to`, do not send push.

- Implement in `send-push-notification` (centralized)
- Respect for both consumer and business

---

## Implementation order

```
Phase 1.1  →  Migration consumer_notification_preferences
Phase 1.2  →  Migration business_notification_preferences
Phase 1.3  →  Domain models (Dart)
Phase 1.4  →  Repositories
Phase 1.5  →  Providers
Phase 1.6  →  Clean up ConsumerPreferences + SupabaseConsumerProfileRepository
──────────
Phase 2.1  →  Rewrite BusinessNotificationsScreen
Phase 2.2  →  Refactor NotificationSettingsScreen
──────────
Phase 3.1  →  send-push-notification channel filter + quiet hours
Phase 3.2  →  handle-order-event preference check
Phase 3.3  →  dispatch-nearby-offers preference check
```

## Files affected

### New files
- `lib/features/profile/domain/consumer_notification_preferences.dart`
- `lib/features/profile/domain/consumer_notification_repository.dart`
- `lib/features/profile/data/supabase_consumer_notification_repository.dart`
- `lib/features/business/domain/business_notification_preferences.dart`
- `lib/features/business/domain/business_notification_repository.dart`
- `lib/features/business/data/supabase_business_notification_repository.dart`

### Modified files
- `lib/features/profile/domain/consumer_preferences.dart`
- `lib/features/profile/data/supabase_consumer_profile_repository.dart`
- `lib/features/profile/presentation/profile_providers.dart`
- `lib/features/profile/presentation/notification_settings_screen.dart`
- `lib/features/business/presentation/business_providers.dart`
- `lib/features/business/presentation/notifications/business_notifications_screen.dart`
- `supabase/functions/send-push-notification/index.ts`
- `supabase/functions/handle-order-event/index.ts`
- `supabase/functions/dispatch-nearby-offers/index.ts`

### New migrations
- `supabase/migrations/20260615000005_create_consumer_notification_preferences.sql`
- `supabase/migrations/20260615000006_create_business_notification_preferences.sql`
