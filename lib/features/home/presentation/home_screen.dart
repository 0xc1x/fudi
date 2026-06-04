import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../../../core/error/user_friendly_message.dart';
import '../../../core/routing/route_names.dart';
import '../../../core/ui/fudi_logo.dart';
import '../../../core/ui/cards/deal_card.dart';
import '../../../core/ui/fudi_colors.dart';
import '../../../core/ui/atoms/icons/fudi_icons.dart';
import '../../../core/ui/fudi_spacing.dart';
import '../../../core/ui/fudi_typography.dart';
import '../../../core/utils/geo_utils.dart';
import '../../offers/domain/offer.dart';
import '../../offers/domain/offer_repository.dart';
import '../../offers/presentation/offer_providers.dart';
import '../../profile/domain/saved_address_model.dart';
import '../../profile/presentation/profile_providers.dart';
import '../../favorites/presentation/favorites_providers.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String? _selectedCategoryId;

  void _onCategorySelected(String? categoryId) {
    setState(() => _selectedCategoryId = categoryId);
    ref.read(popularOffersProvider.notifier).filterByCategory(categoryId);
    ref.read(nearbyOffersProvider.notifier).filterByCategory(categoryId);
  }

  @override
  Widget build(BuildContext context) {
    final popularAsync = ref.watch(popularOffersProvider);
    final nearbyAsync = ref.watch(nearbyOffersProvider);
    final locationAsync = ref.watch(userLocationProvider);
    final statsAsync = ref.watch(categoryStatsProvider);

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
            ref
                .read(popularOffersProvider.notifier)
                .filterByCategory(_selectedCategoryId);
            ref
                .read(nearbyOffersProvider.notifier)
                .filterByCategory(_selectedCategoryId);
          } else {
            await ref.read(popularOffersProvider.notifier).refresh();
            await ref.read(nearbyOffersProvider.notifier).refresh();
          }
          ref.invalidate(categoryStatsProvider);
        },
        child: CustomScrollView(
          slivers: [
            // ─── Sentry verification button (debug only) ────────────
            if (kDebugMode)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: FilledButton.icon(
                    onPressed: () {
                      // Send a Sentry logger API test log
                      Sentry.logger.fmt.info("Test log from %s", [
                        "Sentry (Fudi App)",
                      ]);
                      // Emit a Sentry test metric
                      Sentry.metrics.count('test_metric_clicks', 1);
                      // Throw the test exception
                      throw StateError(
                        'This is test exception from HomeScreen',
                      );
                    },
                    icon: const Icon(Icons.bug_report),
                    label: const Text(
                      'Probar Sentry (Test Exception + Logs + Metrics)',
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.purple,
                    ),
                  ),
                ),
              ),
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
            SliverToBoxAdapter(
              child: _SectionHeader(
                title: 'Ofertas Populares',
                onSeeAll: () => context.go(RouteNames.explorePath),
              ),
            ),
            popularAsync.when(
              data: (offers) => offers.isEmpty
                  ? const SliverToBoxAdapter(child: _EmptyPopularState())
                  : SliverToBoxAdapter(
                      child: SizedBox(
                        height: 360,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(
                            horizontal: FudiSpacing.lg,
                          ),
                          itemCount: offers.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(width: FudiSpacing.md),
                          itemBuilder: (context, index) {
                            final offer = offers[index];
                            return SizedBox(
                              width: 260,
                              child: _buildDealCard(context, offer),
                            );
                          },
                        ),
                      ),
                    ),
              loading: () =>
                  const SliverToBoxAdapter(child: _PopularLoadingSkeleton()),
              error: (error, _) => SliverToBoxAdapter(
                child: _ErrorState(message: userFriendlyMessage(error)),
              ),
            ),
            if (!hasLocation)
              const SliverToBoxAdapter(child: _LocationPrompt()),
            if (hasLocation) ...[
              SliverToBoxAdapter(
                child: _SectionHeader(
                  title: 'Cerca de Ti',
                  onSeeAll: () => context.go(RouteNames.explorePath),
                ),
              ),
              nearbyAsync.when(
                data: (offers) => offers.isEmpty
                    ? const SliverToBoxAdapter(child: _EmptyNearbyState())
                    : SliverPadding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: FudiSpacing.lg,
                        ),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) => Padding(
                              padding: const EdgeInsets.only(
                                bottom: FudiSpacing.md,
                              ),
                              child: _buildDealCard(context, offers[index]),
                            ),
                            childCount: offers.length,
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
            ],
            const SliverToBoxAdapter(child: SizedBox(height: FudiSpacing.xxl)),
          ],
        ),
      ),
    );
  }

  Widget _buildDealCard(BuildContext context, Offer offer) {
    final distance = _formatDistance(offer);
    final isFavorite = ref.watch(favoritedOfferIdsProvider).contains(offer.id);

    return DealCard(
      imageUrl: offer.imageUrl ?? '',
      businessName: offer.business.name,
      businessType: offer.business.type,
      originalPrice: offer.originalPrice,
      discountedPrice: offer.discountedPrice,
      rating: offer.rating,
      distance: distance,
      availableQuantity: offer.stock,
      pickupUntil: offer.pickupUntilTimeOfDay,
      categoryLabel: offer.categoryLabel.isNotEmpty
          ? offer.categoryLabel
          : null,
      isFavorite: isFavorite,
      onFavoriteToggle: () =>
          ref.read(favoritedOfferIdsProvider.notifier).toggleFavorite(offer.id),
      onTap: () => context.push('/product/${offer.id}'),
    );
  }

  String _formatDistance(Offer offer) {
    final pos = ref.read(userLocationProvider).asData?.value;
    return GeoUtils.formatDistance(
      offer.business.latitude,
      offer.business.longitude,
      userLat: pos?.latitude,
      userLng: pos?.longitude,
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

class _CategoryChips extends StatelessWidget {
  const _CategoryChips({
    required this.stats,
    required this.selectedCategoryId,
    required this.onSelected,
  });

  final List<CategoryStat> stats;
  final String? selectedCategoryId;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    // Add "All" option
    final allStats = [
      const CategoryStat(id: 'all', name: 'Todos', count: 0, emoji: '✨'),
      ...stats,
    ];

    return Container(
      color: FudiColors.background,
      padding: const EdgeInsets.symmetric(vertical: FudiSpacing.md),
      child: SizedBox(
        height: 40,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: FudiSpacing.lg),
          itemCount: allStats.length,
          separatorBuilder: (_, _) => const SizedBox(width: FudiSpacing.sm),
          itemBuilder: (context, index) {
            final cat = allStats[index];
            final catId = cat.id == 'all' ? null : cat.id;
            final isActive = catId == selectedCategoryId;
            return _CategoryChip(
              label: cat.name,
              isActive: isActive,
              onTap: () => onSelected(catId),
            );
          },
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
          color: isActive ? FudiColors.primary : FudiColors.card,
          borderRadius: BorderRadius.circular(FudiRadius.full),
          border: Border.all(
            color: FudiColors.primary.withValues(alpha: 0.5),
            width: isActive ? 1.5 : 1.0,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: FudiColors.primary.withValues(alpha: 0.15),
                    blurRadius: 8,
                    spreadRadius: -1,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            label,
            style: FudiTypography.bodyMedium.copyWith(
              color: isActive
                  ? FudiColors.primaryForeground
                  : FudiColors.foreground,
              fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.onSeeAll});

  final String title;
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
          Text(title, style: FudiTypography.headlineSmall),
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

class _EmptyPopularState extends StatelessWidget {
  const _EmptyPopularState();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(FudiSpacing.xl),
      child: Center(
        child: Column(
          children: [
            Icon(FudiIcons.store, size: 48, color: FudiColors.mutedForeground),
            SizedBox(height: FudiSpacing.md),
            Text(
              'No hay ofertas disponibles ahora',
              style: FudiTypography.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyNearbyState extends StatelessWidget {
  const _EmptyNearbyState();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(FudiSpacing.xl),
      child: Center(
        child: Column(
          children: [
            Icon(
              FudiIcons.mapPinOutline,
              size: 48,
              color: FudiColors.mutedForeground,
            ),
            SizedBox(height: FudiSpacing.md),
            Text(
              'No hay ofertas cerca de ti',
              style: FudiTypography.bodyMedium,
            ),
          ],
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
            Container(height: 180, color: FudiColors.muted),
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
