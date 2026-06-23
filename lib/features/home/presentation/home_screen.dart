import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/error/user_friendly_message.dart';
import '../../../core/routing/route_names.dart';
import '../../../core/ui/fudi_logo.dart';
import '../../../core/ui/cards/deal_card.dart';
import '../../../core/ui/cards/business_card.dart';
import '../../../core/ui/fudi_colors.dart';
import '../../../core/ui/atoms/icons/fudi_icons.dart';
import '../../../core/ui/fudi_spacing.dart';
import '../../../core/ui/fudi_typography.dart';
import '../../../core/utils/geo_utils.dart';
import '../../auth/domain/user_profile.dart';
import '../../auth/presentation/auth_state_provider.dart';
import '../../offers/domain/offer.dart';
import '../../offers/domain/offer_category.dart';
import '../../offers/domain/offer_repository.dart';
import '../../offers/presentation/offer_providers.dart';
import '../../profile/domain/saved_address_model.dart';
import '../../profile/presentation/profile_providers.dart';
import '../../favorites/presentation/favorites_providers.dart';
import 'welcome_message.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String? _selectedCategoryId;

  void _onCategorySelected(String? categoryId) {
    final category = categoryId != null
        ? OfferCategory.fromDb(categoryId)
        : null;
    setState(() => _selectedCategoryId = categoryId);
    ref.read(popularOffersProvider.notifier).filterByCategory(category);
    ref.read(nearbyOffersProvider.notifier).filterByCategory(category);
  }

  @override
  Widget build(BuildContext context) {
    final popularAsync = ref.watch(popularOffersProvider);
    final nearbyAsync = ref.watch(nearbyOffersProvider);
    final locationAsync = ref.watch(userLocationProvider);
    final statsAsync = ref.watch(categoryStatsProvider);
    final expiringAsync = ref.watch(expiringSoonOffersProvider);
    final recentAsync = ref.watch(recentOffersProvider);
    final businessesAsync = ref.watch(nearbyBusinessesProvider);

    final hasLocation =
        locationAsync.whenOrNull(
          data: (position) => position != null,
          error: (_, _) => false,
        ) ??
        false;

    return Scaffold(
      backgroundColor: FudiColors.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: const _HomeAppBar(),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          if (_selectedCategoryId != null) {
            final category = OfferCategory.fromDb(_selectedCategoryId);
            ref.read(popularOffersProvider.notifier).filterByCategory(category);
            ref.read(nearbyOffersProvider.notifier).filterByCategory(category);
          } else {
            await ref.read(popularOffersProvider.notifier).refresh();
            await ref.read(nearbyOffersProvider.notifier).refresh();
          }
          await ref.read(expiringSoonOffersProvider.notifier).refresh();
          await ref.read(recentOffersProvider.notifier).refresh();
          await ref.read(nearbyBusinessesProvider.notifier).refresh();
          ref.invalidate(categoryStatsProvider);
        },
        child: CustomScrollView(
          slivers: [
            // ── Bienvenida ───────────────────────────────────────────
            const SliverToBoxAdapter(child: _WelcomeBanner()),

            // ── Categorías ───────────────────────────────────────────
            statsAsync.when(
              data: (stats) => SliverToBoxAdapter(
                child: _CategoryChips(
                  stats: stats,
                  selectedCategoryId: _selectedCategoryId,
                  onSelected: _onCategorySelected,
                ),
              ),
              loading: () =>
                  const SliverToBoxAdapter(child: SizedBox(height: 40)),
              error: (_, _) =>
                  const SliverToBoxAdapter(child: SizedBox.shrink()),
            ),

            // ── Tips de Rescate ──────────────────────────────────────
            const SliverToBoxAdapter(child: _PromoSlider()),

            // ── Últimas Horas ────────────────────────────────────────
            expiringAsync.when(
              data: (offers) => offers.isEmpty
                  ? const SliverToBoxAdapter(child: SizedBox.shrink())
                  : SliverToBoxAdapter(
                      child: _OfferRowSection(
                        title: 'Últimas Horas',
                        icon: FudiIcons.clock,
                        offers: offers,
                        onSeeAll: () => context.push(
                          RouteNames.allOffersPath,
                          extra: AllOffersView.expiring,
                        ),
                      ),
                    ),
              loading: () => const SliverToBoxAdapter(child: SizedBox.shrink()),
              error: (_, _) =>
                  const SliverToBoxAdapter(child: SizedBox.shrink()),
            ),

            // ── Recién Agregados ─────────────────────────────────────
            recentAsync.when(
              data: (offers) => offers.isEmpty
                  ? const SliverToBoxAdapter(child: SizedBox.shrink())
                  : SliverToBoxAdapter(
                      child: _OfferRowSection(
                        title: 'Recién Agregados',
                        icon: FudiIcons.trendingUp,
                        offers: offers,
                        onSeeAll: () => context.push(
                          RouteNames.allOffersPath,
                          extra: AllOffersView.recent,
                        ),
                      ),
                    ),
              loading: () => const SliverToBoxAdapter(child: SizedBox.shrink()),
              error: (_, _) =>
                  const SliverToBoxAdapter(child: SizedBox.shrink()),
            ),

            // ── Ofertas Populares ────────────────────────────────────
            popularAsync.when(
              data: (offers) => offers.isEmpty
                  ? const SliverToBoxAdapter(child: SizedBox.shrink())
                  : SliverToBoxAdapter(
                      child: _OfferRowSection(
                        title: 'Ofertas Populares',
                        icon: FudiIcons.trendingUp,
                        offers: offers,
                        onSeeAll: () => context.push(
                          RouteNames.allOffersPath,
                          extra: AllOffersView.popular,
                        ),
                      ),
                    ),
              loading: () =>
                  const SliverToBoxAdapter(child: _PopularLoadingSkeleton()),
              error: (error, _) => SliverToBoxAdapter(
                child: _ErrorState(message: userFriendlyMessage(error)),
              ),
            ),

            // ── Negocios Cerca ───────────────────────────────────────
            businessesAsync.when(
              data: (businesses) => businesses.isEmpty
                  ? const SliverToBoxAdapter(child: SizedBox.shrink())
                  : SliverToBoxAdapter(
                      child: _BusinessesRowSection(
                        businesses: businesses,
                        onSeeAll: () =>
                            context.push(RouteNames.allBusinessesPath),
                      ),
                    ),
              loading: () => const SliverToBoxAdapter(child: SizedBox.shrink()),
              error: (_, _) =>
                  const SliverToBoxAdapter(child: SizedBox.shrink()),
            ),

            // ── Cerca de Ti ─────────────────────────────────────────
            if (!hasLocation)
              const SliverToBoxAdapter(child: _LocationPrompt()),
            if (hasLocation)
              nearbyAsync.when(
                data: (offers) => offers.isEmpty
                    ? const SliverToBoxAdapter(child: SizedBox.shrink())
                    : SliverToBoxAdapter(
                        child: _OfferColumnSection(
                          title: 'Cerca de Ti',
                          offers: offers,
                          onSeeAll: () => context.push(
                            RouteNames.allOffersPath,
                            extra: AllOffersView.nearby,
                          ),
                        ),
                      ),
                loading: () => SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: FudiSpacing.lg,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, _) => const _DealCardSkeleton(),
                      childCount: 3,
                    ),
                  ),
                ),
                error: (error, _) => SliverToBoxAdapter(
                  child: _ErrorState(message: userFriendlyMessage(error)),
                ),
              ),

            const SliverToBoxAdapter(child: SizedBox(height: FudiSpacing.xxl)),
          ],
        ),
      ),
    );
  }
}

class _HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _HomeAppBar();

  @override
  Size get preferredSize => const Size.fromHeight(2000);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: FudiColors.background,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      title: const _LocationSelector(),
      centerTitle: false,
      actions: const [
        Padding(
          padding: EdgeInsets.only(right: FudiSpacing.md),
          child: FudiLogo(
            variant: FudiLogoVariant.wordmark,
            size: FudiLogoSize.xxl,
          ),
        ),
      ],
    );
  }
}

class _LocationSelector extends ConsumerStatefulWidget {
  const _LocationSelector();

  @override
  ConsumerState<_LocationSelector> createState() => _LocationSelectorState();
}

class _LocationSelectorState extends ConsumerState<_LocationSelector>
    with SingleTickerProviderStateMixin {
  bool _isOpen = false;
  late AnimationController _chevronController;
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();

  @override
  void initState() {
    super.initState();
    _chevronController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  void dispose() {
    _removeOverlay();
    _chevronController.dispose();
    super.dispose();
  }

  void _toggleDropdown() {
    if (_isOpen) {
      _closeDropdown();
    } else {
      _openDropdown();
    }
  }

  void _openDropdown() {
    final overlay = Overlay.of(context);
    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;

    _overlayEntry = OverlayEntry(
      builder: (context) => _LocationDropdownOverlay(
        layerLink: _layerLink,
        buttonWidth: size.width,
        onClose: _closeDropdown,
        onAddressSelected: _onAddressSelected,
        onAddAddress: _onAddAddress,
      ),
    );

    overlay.insert(_overlayEntry!);
    setState(() => _isOpen = true);
    _chevronController.forward();
  }

  void _closeDropdown() {
    _removeOverlay();
    if (mounted) {
      setState(() => _isOpen = false);
      _chevronController.reverse();
    }
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _onAddressSelected(SavedAddressModel address) {
    ref.read(userSelectedAddressProvider.notifier).select(address);
    _closeDropdown();
  }

  void _onAddAddress() {
    _closeDropdown();
    context.push(RouteNames.savedAddressesPath);
  }

  @override
  Widget build(BuildContext context) {
    final selectedAddress = ref.watch(userSelectedAddressProvider);

    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        onTap: _toggleDropdown,
        behavior: HitTestBehavior.opaque,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(FudiIcons.mapPin, size: 16, color: FudiColors.primary),
            const SizedBox(width: FudiSpacing.xs),
            Text(
              selectedAddress?.label ?? 'Seleccionar ubicación',
              style: const TextStyle(
                fontFamily: 'DMSans',
                color: FudiColors.foreground,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(width: 2),
            RotationTransition(
              turns: Tween(begin: 0.0, end: 0.5).animate(_chevronController),
              child: const Icon(
                FudiIcons.chevronDown,
                size: 16,
                color: FudiColors.foreground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Full-screen dismiss barrier + positioned dropdown panel.
///
/// Uses [ConsumerWidget] to access providers directly instead of passing
/// [WidgetRef] through the constructor — avoids stale-ref issues.
class _LocationDropdownOverlay extends ConsumerWidget {
  const _LocationDropdownOverlay({
    required this.layerLink,
    required this.buttonWidth,
    required this.onClose,
    required this.onAddressSelected,
    required this.onAddAddress,
  });

  final LayerLink layerLink;
  final double buttonWidth;
  final VoidCallback onClose;
  final ValueChanged<SavedAddressModel> onAddressSelected;
  final VoidCallback onAddAddress;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final addressesAsync = ref.watch(savedAddressesProvider);
    final selectedAddress = ref.watch(userSelectedAddressProvider);

    return Stack(
      children: [
        // Dismiss barrier — covers entire screen
        Positioned.fill(
          child: GestureDetector(
            onTap: onClose,
            behavior: HitTestBehavior.opaque,
            child: const ColoredBox(color: Colors.transparent),
          ),
        ),
        // Dropdown panel positioned below the selector button
        CompositedTransformFollower(
          link: layerLink,
          showWhenUnlinked: false,
          offset: const Offset(0, _kDropdownTopOffset),
          child: Material(
            color: Colors.transparent,
            child: Container(
              constraints: BoxConstraints(
                minWidth: buttonWidth,
                maxWidth: _kDropdownMaxWidth,
              ),
              decoration: BoxDecoration(
                color: FudiColors.inputBackground,
                borderRadius: BorderRadius.circular(FudiRadius.xl),
                border: Border.all(color: FudiColors.borderSolid),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x1A000000),
                    blurRadius: 20,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: addressesAsync.when(
                data: (addresses) => _DropdownContent(
                  addresses: addresses,
                  selectedAddress: selectedAddress,
                  onAddressSelected: onAddressSelected,
                  onAddAddress: onAddAddress,
                ),
                loading: () => const Padding(
                  padding: EdgeInsets.all(FudiSpacing.lg),
                  child: Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                ),
                error: (_, _) => Padding(
                  padding: const EdgeInsets.all(FudiSpacing.lg),
                  child: Text(
                    'Error al cargar direcciones',
                    style: FudiTypography.bodySmall.copyWith(
                      color: FudiColors.destructive,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Inner content of the dropdown: address list + add link.
class _DropdownContent extends StatelessWidget {
  const _DropdownContent({
    required this.addresses,
    required this.selectedAddress,
    required this.onAddressSelected,
    required this.onAddAddress,
  });

  final List<SavedAddressModel> addresses;
  final SavedAddressModel? selectedAddress;
  final ValueChanged<SavedAddressModel> onAddressSelected;
  final VoidCallback onAddAddress;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Address list
        for (final address in addresses)
          _AddressItem(
            address: address,
            isSelected: address.id == selectedAddress?.id,
            onTap: () => onAddressSelected(address),
          ),
        // Divider + add new address link
        const Divider(height: 1, thickness: 1, color: FudiColors.borderSolid),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: FudiSpacing.lg,
            vertical: FudiSpacing.md,
          ),
          child: GestureDetector(
            onTap: onAddAddress,
            child: Text(
              '+ Agregar nueva dirección',
              style: FudiTypography.bodyMedium.copyWith(
                color: FudiColors.primary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Single address row in the dropdown.
class _AddressItem extends StatelessWidget {
  const _AddressItem({
    required this.address,
    required this.isSelected,
    required this.onTap,
  });

  final SavedAddressModel address;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        color: isSelected ? const Color(0x0DFA4743) : null,
        padding: const EdgeInsets.symmetric(
          horizontal: FudiSpacing.lg,
          vertical: FudiSpacing.md,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Map pin icon — primary if selected, muted otherwise
            Icon(
              FudiIcons.mapPin,
              size: 16,
              color: isSelected
                  ? FudiColors.primary
                  : FudiColors.mutedForeground,
            ),
            const SizedBox(width: FudiSpacing.sm),
            // Name + address
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    address.label,
                    style: FudiTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.w500,
                      color: isSelected
                          ? FudiColors.primary
                          : FudiColors.foreground,
                    ),
                  ),
                  Text(address.address, style: FudiTypography.bodySmall),
                ],
              ),
            ),
            // Blue dot indicator for selected
            if (isSelected) ...[
              const SizedBox(width: FudiSpacing.sm),
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(top: 4),
                decoration: const BoxDecoration(
                  color: FudiColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Layout constants for the dropdown overlay.
const double _kDropdownTopOffset = 8.0;
const double _kDropdownMaxWidth = 280.0;

class _WelcomeBanner extends ConsumerStatefulWidget {
  const _WelcomeBanner();

  @override
  ConsumerState<_WelcomeBanner> createState() => _WelcomeBannerState();
}

class _WelcomeBannerState extends ConsumerState<_WelcomeBanner> {
  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authSessionNotifierProvider);
    final profile = authState.profile;

    if (profile == null || authState.role != UserRole.user) {
      return const SizedBox.shrink();
    }

    final data = WelcomeMessage.generate(profile: profile, now: DateTime.now());

    return Container(
      margin: const EdgeInsets.fromLTRB(
        FudiSpacing.lg,
        FudiSpacing.md,
        FudiSpacing.lg,
        FudiSpacing.sm,
      ),
      padding: const EdgeInsets.fromLTRB(
        FudiSpacing.lg,
        FudiSpacing.lg,
        FudiSpacing.lg,
        FudiSpacing.md,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            FudiColors.accent,
            FudiColors.accent.withValues(alpha: 0.92),
          ],
        ),
        borderRadius: BorderRadius.circular(FudiRadius.xl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(data.emoji, style: const TextStyle(fontSize: 28)),
              const SizedBox(width: FudiSpacing.sm),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '${data.greeting}, ',
                        style: FudiTypography.h2.copyWith(
                          color: FudiColors.accentForeground,
                        ),
                      ),
                      TextSpan(
                        text: data.displayName,
                        style: FudiTypography.h2.copyWith(
                          color: FudiColors.secondary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: FudiSpacing.xs),
          Padding(
            padding: const EdgeInsets.only(
              left: FudiSpacing.xl + FudiSpacing.sm + FudiSpacing.xs,
            ),
            child: Text(
              data.contextualMessage,
              style: FudiTypography.bodyMedium.copyWith(
                color: FudiColors.accentForeground.withValues(alpha: 0.8),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryChips extends ConsumerStatefulWidget {
  const _CategoryChips({
    required this.stats,
    required this.selectedCategoryId,
    required this.onSelected,
  });

  final List<CategoryStat> stats;
  final String? selectedCategoryId;
  final ValueChanged<String?> onSelected;

  @override
  ConsumerState<_CategoryChips> createState() => _CategoryChipsState();
}

class _CategoryChipsState extends ConsumerState<_CategoryChips> {
  bool _showAll = false;
  static const _initialCount = 5;

  @override
  Widget build(BuildContext context) {
    final allStats = [
      const CategoryStat(id: 'all', name: 'Todos', count: 0, emoji: '✨'),
      ...widget.stats,
    ];
    final display = _showAll ? allStats : allStats.take(_initialCount).toList();
    final remaining = allStats.length - _initialCount;

    final showMore = !_showAll && remaining > 0;
    final showLess = _showAll && allStats.length > _initialCount;
    final extraChips = (showMore || showLess) ? 1 : 0;

    return Container(
      color: FudiColors.background,
      padding: const EdgeInsets.symmetric(vertical: FudiSpacing.md),
      child: SizedBox(
        height: 40,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: FudiSpacing.lg),
          itemCount: display.length + extraChips,
          separatorBuilder: (_, _) => const SizedBox(width: FudiSpacing.sm),
          itemBuilder: (context, index) {
            if (showMore && index == display.length) {
              return _MoreChip(
                label: '+$remaining',
                onTap: () => setState(() => _showAll = true),
              );
            }
            if (showLess && index == display.length) {
              return _MoreChip(
                label: 'Ver menos',
                onTap: () => setState(() => _showAll = false),
              );
            }
            final cat = display[index];
            final catId = cat.id == 'all' ? null : cat.id;
            final isActive = catId == widget.selectedCategoryId;
            return _CategoryChip(
              label: cat.name,
              isActive: isActive,
              onTap: () => widget.onSelected(catId),
            );
          },
        ),
      ),
    );
  }
}

class _MoreChip extends StatelessWidget {
  const _MoreChip({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: FudiSpacing.lg,
          vertical: FudiSpacing.sm,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(FudiRadius.full),
          border: Border.all(color: FudiColors.borderSolid),
        ),
        child: Center(
          child: Text(
            label,
            style: FudiTypography.bodyMedium.copyWith(
              color: FudiColors.mutedForeground,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(
          horizontal: FudiSpacing.lg,
          vertical: FudiSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isActive
              ? FudiColors.accent
              : FudiColors.muted.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(FudiRadius.full),
          border: Border.all(
            color: isActive
                ? FudiColors.accent
                : FudiColors.accent.withValues(alpha: 0.15),
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: FudiTypography.bodyMedium.copyWith(
              color: isActive
                  ? FudiColors.accentForeground
                  : FudiColors.accent.withValues(alpha: 0.7),
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

class _LocationPrompt extends StatelessWidget {
  const _LocationPrompt();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(FudiSpacing.lg),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(FudiSpacing.md),
          child: Row(
            children: [
              const Icon(FudiIcons.mapPin, color: FudiColors.primary),
              const SizedBox(width: FudiSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Activa tu ubicación',
                      style: FudiTypography.labelMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Para ver ofertas cerca de ti',
                      style: FudiTypography.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(FudiSpacing.lg),
      child: Center(
        child: Column(
          children: [
            const Icon(
              FudiIcons.error,
              size: 48,
              color: FudiColors.destructive,
            ),
            const SizedBox(height: FudiSpacing.sm),
            Text('Error al cargar', style: FudiTypography.bodyMedium),
          ],
        ),
      ),
    );
  }
}

class _PopularLoadingSkeleton extends StatelessWidget {
  const _PopularLoadingSkeleton();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 360,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: FudiSpacing.lg),
        itemCount: 3,
        separatorBuilder: (_, _) => const SizedBox(width: FudiSpacing.md),
        itemBuilder: (_, _) =>
            const SizedBox(width: 260, child: _DealCardSkeleton()),
      ),
    );
  }
}

/// Sección horizontal de ofertas en fila (Últimas Horas, Recién Agregados, Populares).
class _OfferRowSection extends StatelessWidget {
  const _OfferRowSection({
    required this.title,
    required this.icon,
    required this.offers,
    this.onSeeAll,
  });

  final String title;
  final IconData icon;
  final List<Offer> offers;
  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(title: title, icon: icon, onSeeAll: onSeeAll),
        SizedBox(
          height: 320,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: FudiSpacing.lg),
            itemCount: offers.length,
            separatorBuilder: (_, _) => const SizedBox(width: FudiSpacing.md),
            itemBuilder: (context, index) {
              final offer = offers[index];
              return SizedBox(width: 260, child: _HomeDealCard(offer: offer));
            },
          ),
        ),
      ],
    );
  }
}

/// Sección vertical de ofertas (Cerca de Ti).
class _OfferColumnSection extends StatelessWidget {
  const _OfferColumnSection({
    required this.title,
    required this.offers,
    this.onSeeAll,
  });

  final String title;
  final List<Offer> offers;
  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(title: title, onSeeAll: onSeeAll),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: FudiSpacing.lg),
          child: Column(
            children: offers.map((offer) {
              return Padding(
                padding: const EdgeInsets.only(bottom: FudiSpacing.md),
                child: _HomeDealCard(offer: offer, fullWidth: true),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

/// Sección horizontal de negocios.
class _BusinessesRowSection extends StatelessWidget {
  const _BusinessesRowSection({required this.businesses, this.onSeeAll});

  final List<BusinessSummary> businesses;
  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          title: 'Negocios Cerca',
          icon: FudiIcons.store,
          onSeeAll: onSeeAll,
        ),
        SizedBox(
          height: 100,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: FudiSpacing.lg),
            itemCount: businesses.length,
            separatorBuilder: (_, _) => const SizedBox(width: FudiSpacing.md),
            itemBuilder: (context, index) {
              final business = businesses[index];
              return SizedBox(
                width: 280,
                child: _HomeBusinessCard(business: business),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Tips de rescate estáticos.
/// Item de contenido para el slider promocional.
///
/// Extensible: en futuro puede representar anuncios, ofertas, comunicados, etc.
/// Item de contenido para el slider promocional.
///
/// Extensible: en futuro puede recibir [iconColor], [backgroundColor],
/// [borderColor], [onTap] para anuncios, ofertas o comunicados.
class _PromoItem {
  const _PromoItem({required this.title, required this.message, this.icon});

  final String title;
  final String message;
  final IconData? icon;
}

/// Slider auto-rotante de contenido promocional (tips, anuncios, ofertas…).
class _PromoSlider extends StatefulWidget {
  const _PromoSlider();

  @override
  State<_PromoSlider> createState() => _PromoSliderState();
}

class _PromoSliderState extends State<_PromoSlider> {
  final _pageController = PageController();
  Timer? _timer;
  int _currentPage = 0;
  bool _isPaused = false;

  static const _items = [
    _PromoItem(
      title: '¿Sabías que…',
      message:
          'Cada año se desperdician 1.3 mil millones de toneladas de comida en el mundo. ¡Tú puedes ayudar!',
      icon: FudiIcons.info,
    ),
    _PromoItem(
      title: 'Impacto ambiental',
      message:
          'Al rescatar un paquete sorpresa evitas la emisión de ~2.5kg de CO2. Cada rescate cuenta.',
      icon: FudiIcons.trendingUp,
    ),
    _PromoItem(
      title: 'Comida rescatada',
      message:
          'Los alimentos aptos para consumo pero no para venta son rescatados por negocios como los de Fudi.',
      icon: FudiIcons.package_,
    ),
    _PromoItem(
      title: 'Gana-gana',
      message:
          'Rescatar comida no solo ahorra dinero, también reduce el desperdicio y apoya a negocios locales.',
      icon: FudiIcons.star,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _startAutoRotate();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoRotate() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!_isPaused && _items.length > 1) {
        final next = (_currentPage + 1) % _items.length;
        _pageController.animateToPage(
          next,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_items.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        FudiSpacing.lg,
        FudiSpacing.md,
        FudiSpacing.lg,
        0,
      ),
      child: Column(
        children: [
          SizedBox(
            height: 110,
            child: Listener(
              onPointerDown: (_) => setState(() => _isPaused = true),
              onPointerUp: (_) => setState(() => _isPaused = false),
              onPointerCancel: (_) => setState(() => _isPaused = false),
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (page) => setState(() => _currentPage = page),
                itemCount: _items.length,
                itemBuilder: (context, index) {
                  final item = _items[index];
                  return _PromoCard(item: item);
                },
              ),
            ),
          ),
          if (_items.length > 1) ...[
            const SizedBox(height: FudiSpacing.sm),
            _PageDots(count: _items.length, current: _currentPage),
          ],
        ],
      ),
    );
  }
}

/// Card individual dentro del slider promocional.
class _PromoCard extends StatelessWidget {
  const _PromoCard({required this.item});

  final _PromoItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(FudiSpacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            FudiColors.primary.withValues(alpha: 0.08),
            FudiColors.accent.withValues(alpha: 0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(FudiRadius.lg),
        border: Border.all(color: FudiColors.primary.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          if (item.icon != null) ...[
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: FudiColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(FudiRadius.sm),
              ),
              child: Icon(item.icon, size: 18, color: FudiColors.primary),
            ),
            const SizedBox(width: FudiSpacing.md),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  item.title,
                  style: FudiTypography.labelSmall.copyWith(
                    fontSize: 13,
                    color: FudiColors.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.message,
                  style: FudiTypography.bodySmall.copyWith(
                    fontSize: 12,
                    height: 1.4,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Indicadores de página (puntos).
class _PageDots extends StatelessWidget {
  const _PageDots({required this.count, required this.current});

  final int count;
  final int current;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        final isActive = index == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: isActive ? 20 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive
                ? FudiColors.primary
                : FudiColors.mutedForeground.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}

/// Wrapper around DealCard that provides distance and favorites from context.
class _HomeDealCard extends ConsumerWidget {
  const _HomeDealCard({required this.offer, this.fullWidth = false});

  final Offer offer;
  final bool fullWidth;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pos = ref.read(userLocationProvider).asData?.value;
    final distance = GeoUtils.formatDistance(
      offer.business.latitude,
      offer.business.longitude,
      userLat: pos?.latitude,
      userLng: pos?.longitude,
    );
    final isFavorite = ref.watch(favoritedOfferIdsProvider).contains(offer.id);

    return DealCard(
      imageUrl: offer.imageUrl ?? offer.business.imageUrl ?? '',
      businessName: offer.business.name,
      originalPrice: offer.originalPrice,
      discountedPrice: offer.discountedPrice,
      rating: offer.rating,
      distance: distance,
      availableQuantity: offer.stock,
      pickupUntil: offer.pickupUntilTimeOfDay,
      categoryLabel: offer.categoryLabel,
      isFavorite: isFavorite,
      onFavoriteToggle: () =>
          ref.read(favoritedOfferIdsProvider.notifier).toggleFavorite(offer.id),
      onTap: () => context.push('/product/${offer.id}'),
    );
  }
}

/// Wrapper around BusinessCard that provides distance from context.
class _HomeBusinessCard extends ConsumerWidget {
  const _HomeBusinessCard({required this.business});

  final BusinessSummary business;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pos = ref.read(userLocationProvider).asData?.value;
    final distance = GeoUtils.formatDistance(
      business.latitude,
      business.longitude,
      userLat: pos?.latitude,
      userLng: pos?.longitude,
    );

    return BusinessCard(
      imageUrl: business.imageUrl ?? '',
      name: business.name,
      type: business.type,
      rating: business.rating,
      distance: distance,
      activeDealsCount: business.activeDealsCount,
      onTap: () => context.push(
        RouteNames.businessProfileViewPath.replaceAll(':id', business.id),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.icon, this.onSeeAll});

  final String title;
  final IconData? icon;
  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        FudiSpacing.lg,
        FudiSpacing.lg,
        FudiSpacing.lg,
        FudiSpacing.sm,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18, color: FudiColors.primary),
                const SizedBox(width: 6),
              ],
              Text(title, style: FudiTypography.headlineSmall),
            ],
          ),
          if (onSeeAll != null)
            TextButton(
              onPressed: onSeeAll,
              child: Text(
                'Ver todo',
                style: FudiTypography.bodySmall.copyWith(
                  color: FudiColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _DealCardSkeleton extends StatelessWidget {
  const _DealCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: FudiColors.muted,
      highlightColor: Colors.white,
      child: Material(
        color: FudiColors.muted,
        borderRadius: BorderRadius.circular(FudiRadius.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(height: 200, color: FudiColors.muted),
            const Padding(
              padding: EdgeInsets.all(FudiSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 14,
                    width: 160,
                    child: DecoratedBox(
                      decoration: BoxDecoration(color: FudiColors.muted),
                    ),
                  ),
                  SizedBox(height: 8),
                  SizedBox(
                    height: 10,
                    width: 100,
                    child: DecoratedBox(
                      decoration: BoxDecoration(color: FudiColors.muted),
                    ),
                  ),
                  SizedBox(height: 12),
                  SizedBox(
                    height: 10,
                    width: 200,
                    child: DecoratedBox(
                      decoration: BoxDecoration(color: FudiColors.muted),
                    ),
                  ),
                  SizedBox(height: 12),
                  SizedBox(
                    height: 1,
                    child: DecoratedBox(
                      decoration: BoxDecoration(color: FudiColors.muted),
                    ),
                  ),
                  SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        height: 14,
                        width: 80,
                        child: DecoratedBox(
                          decoration: BoxDecoration(color: FudiColors.muted),
                        ),
                      ),
                      SizedBox(
                        height: 32,
                        width: 90,
                        child: DecoratedBox(
                          decoration: BoxDecoration(color: FudiColors.muted),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
