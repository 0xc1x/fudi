# CHANGELOG

## [0.3.0] - 2026-05-07

### Added
- **Phase 3: Auth** completed.
- `LoginScreen` with email/password, validation, and "Forgot password" dialog.
- `SignupScreen` with role selection (Consumer/Business) and analytics consent.
- `UpdatePasswordScreen` for secure password reset flow.
- `SupabaseAuthRepository` implementation for robust session management.
- `AuthSessionNotifier` for reactive UI state and session expiration signaling.
- `AuthFeedbackListener` for global session notifications (SnackBars).
- Sentry breadcrumbs for all auth actions (submit, logout, reset).
- Analytics events tracking for auth funnels (started, completed, failed, logout).

### Fixed
- UI synchronization when clearing password recovery flags in `AuthSessionNotifier`.

## [0.2.0] - 2026-05-07

### Added
- **Phase 2: Database Schema** baseline established in Supabase.
- RLS (Row Level Security) policies for `profiles`, `businesses`, `offers`, and `orders`.
- Edge Functions for atomic operations: `reserve-offer`.
- Database documentation and tracking system in `docs/database/`.

## [0.1.0] - 2026-05-07

### Added
- **Phase 1: Core Layer** foundation established.
- `FudiException` hierarchy for standardized error handling.
- Sentry and Analytics services integration.
- Network layer with retry policy and circuit breaker.
- `GoRouter` configuration with 40+ routes and role-based guards.
- Project structure following Clean Architecture + Feature-First.
