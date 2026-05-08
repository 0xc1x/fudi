# CHANGELOG

## [0.4.0] - 2026-05-07

### Added
- **Phase 4: UI Components** completed.
- High-fidelity Design Tokens: `FudiColors`, `FudiTypography`, `FudiSpacing`, `FudiRadius`.
- Centralized `FudiTheme` (Light/Dark) following Material 3.
- `FudiScaffold` with built-in `_OfflineBanner` and corporate `AppBar`.
- Adaptive `FudiBottomNav` supporting automatic switching between Consumer and Business modes.
- Core UI Cards: `DealCard`, `OrderCard`, and `BusinessCard`.
- `FudiLogo` and `FudiStarRating` atomic components.
- `UiGalleryScreen` for component verification and testing.
- `AppModeNotifier` for managing Consumer/Business mode state based on user role.
- Persistent navigation structure using `ShellRoute` in `GoRouter`.

### Fixed
- Analysis warnings related to deprecated `withOpacity` (replaced with `withValues`).
- Cleanup of unused fields and imports in `RouteGuards` and `AppRouter`.

## [0.3.0] - 2026-05-07

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
