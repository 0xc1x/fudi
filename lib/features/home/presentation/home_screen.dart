import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/routing/route_names.dart';
import '../../../core/ui/app_logo.dart';
import '../../../core/ui/cards/deal_card.dart';
import '../../../core/ui/fudi_colors.dart';
import '../../../core/ui/fudi_icons.dart';
import '../../../core/ui/fudi_spacing.dart';
import '../../../core/ui/fudi_typography.dart';
import '../../offers/domain/offer.dart';
import '../../offers/presentation/offer_providers.dart';

const _categories = [
  (id: null, name: 'Todos'),
  (id: 'bakery', name: 'Panadería'),
  (id: 'cafe', name: 'Cafeterías'),
  (id: 'italian', name: 'Italiano'),
  (id: 'japanese', name: 'Japonés'),
];

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String? _selectedCategoryId;

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Buenos días';
    if (hour < 18) return 'Buenas tardes';
    return 'Buenas noches';
  }

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

    final hasLocation =
        locationAsync.whenOrNull(
          data: (position) => position != null,
          error: (_, _) => false,
        ) ??
        false;

    return Scaffold(
      body: RefreshIndicator(
      onRefresh: () async {
        if (_selectedCategoryId != null) {
          ref.read(popularOffersProvider.notifier).filterByCategory(_selectedCategoryId);
          ref.read(nearbyOffersProvider.notifier).filterByCategory(_selectedCategoryId);
        } else {
          ref.read(popularOffersProvider.notifier).refresh();
          ref.read(nearbyOffersProvider.notifier).refresh();
        }
      },
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _HomeHeader(greeting: _greeting)),
        SliverToBoxAdapter(
          child: _CategoryChips(
            selectedCategoryId: _selectedCategoryId,
            onSelected: _onCategorySelected,
          ),
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
                child: _ErrorState(message: error.toString()),
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
                  child: _ErrorState(message: error.toString()),
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
      onTap: () => context.go('/product/${offer.id}'),
    );
  }

  String _formatDistance(Offer offer) {
    if (offer.business.latitude == null || offer.business.longitude == null) {
      return '';
    }
    return '${offer.business.latitude!.toStringAsFixed(1)}km';
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({required this.greeting});

  final String greeting;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: FudiColors.ring,
      padding: const EdgeInsets.fromLTRB(
        FudiSpacing.lg,
        FudiSpacing.lg + 8,
        FudiSpacing.lg,
        FudiSpacing.lg,
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      greeting,
                      style: FudiTypography.bodyMedium.copyWith(
                        color: FudiColors.primary,
                      ),
                    ),
                    const SizedBox(height: FudiSpacing.xs),
                    const _LocationSelector(),
                  ],
                ),
                const AppLogo(
                  size: AppLogoSize.lg,
                  variant: AppLogoVariant.light,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LocationSelector extends StatefulWidget {
  const _LocationSelector();

  @override
  State<_LocationSelector> createState() => _LocationSelectorState();
}

class _LocationSelectorState extends State<_LocationSelector> {
  final _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool _isOpen = false;
  int _selectedIndex = 0;

  static const _locations = [
    (name: 'Casa', address: 'Bogotá, Colombia'),
    (name: 'Trabajo', address: 'Centro, Bogotá'),
  ];

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _toggleDropdown() {
    setState(() => _isOpen = !_isOpen);
    if (_isOpen) {
      _showDropdown();
    } else {
      _removeOverlay();
    }
  }

  void _showDropdown() {
    final overlay = Overlay.of(context);
    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;

    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: () {
                setState(() => _isOpen = false);
                _removeOverlay();
              },
              behavior: HitTestBehavior.opaque,
              child: const SizedBox.expand(),
            ),
          ),
          CompositedTransformFollower(
            link: _layerLink,
            offset: Offset(0, size.height + FudiSpacing.sm),
            child: Material(
              color: FudiColors.background,
              borderRadius: BorderRadius.circular(FudiRadius.lg),
              elevation: 8,
              child: Container(
                constraints: const BoxConstraints(minWidth: 150),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(FudiRadius.lg),
                  border: Border.all(color: FudiColors.borderSolid),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(FudiRadius.lg),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (var i = 0; i < _locations.length; i++)
                        _LocationOption(
                          name: _locations[i].name,
                          address: _locations[i].address,
                          isSelected: i == _selectedIndex,
                          onTap: () {
                            setState(() => _selectedIndex = i);
                            setState(() => _isOpen = false);
                            _removeOverlay();
                          },
                        ),
                      const Divider(height: 1, thickness: 1),
                      InkWell(
                        onTap: () {
                          setState(() => _isOpen = false);
                          _removeOverlay();
                          GoRouter.of(context).go('/profile/addresses');
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: FudiSpacing.lg,
                            vertical: FudiSpacing.md,
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                FudiIcons.mapPin,
                                size: 16,
                                color: FudiColors.primary,
                              ),
                              const SizedBox(width: FudiSpacing.sm),
                              Text(
                                '+ Agregar nueva dirección',
                                style: FudiTypography.bodySmall.copyWith(
                                  color: FudiColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );

    overlay.insert(_overlayEntry!);
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        onTap: _toggleDropdown,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(FudiIcons.mapPin, size: 16, color: FudiColors.primary),
            const SizedBox(width: 4),
            Text(
              _locations[_selectedIndex].name,
              style: FudiTypography.labelSmall.copyWith(
                color: FudiColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
            AnimatedRotation(
              turns: _isOpen ? 0.5 : 0,
              duration: const Duration(milliseconds: 200),
              child: const Icon(
                FudiIcons.chevronDown,
                size: 16,
                color: FudiColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LocationOption extends StatelessWidget {
  const _LocationOption({
    required this.name,
    required this.address,
    required this.isSelected,
    required this.onTap,
  });

  final String name;
  final String address;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        color: isSelected ? FudiColors.primary.withValues(alpha: 0.05) : null,
        padding: const EdgeInsets.symmetric(
          horizontal: FudiSpacing.lg,
          vertical: FudiSpacing.md,
        ),
        child: Row(
          children: [
            Icon(
              FudiIcons.mapPin,
              size: 16,
              color: isSelected
                  ? FudiColors.primary
                  : FudiColors.mutedForeground,
            ),
            const SizedBox(width: FudiSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: FudiTypography.bodySmall.copyWith(
                      fontWeight: FontWeight.w500,
                      color: isSelected
                          ? FudiColors.primary
                          : FudiColors.foreground,
                    ),
                  ),
                  Text(
                    address,
                    style: const TextStyle(
                      fontSize: 11,
                      color: FudiColors.mutedForeground,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: FudiColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _CategoryChips extends StatelessWidget {
  const _CategoryChips({
    required this.selectedCategoryId,
    required this.onSelected,
  });

  final String? selectedCategoryId;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: FudiColors.background,
      padding: const EdgeInsets.symmetric(vertical: FudiSpacing.md),
      child: SizedBox(
        height: 40,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: FudiSpacing.lg),
          itemCount: _categories.length,
          separatorBuilder: (_, _) => const SizedBox(width: FudiSpacing.sm),
          itemBuilder: (context, index) {
            final cat = _categories[index];
            final isActive = cat.id == selectedCategoryId;
            return _CategoryChip(
              label: cat.name,
              isActive: isActive,
              onTap: () => onSelected(cat.id),
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
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: FudiSpacing.md,
          vertical: FudiSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isActive ? FudiColors.primary : FudiColors.secondary,
          borderRadius: BorderRadius.circular(FudiRadius.full),
        ),
        child: Text(
          label,
          style: FudiTypography.bodySmall.copyWith(
            color: isActive
                ? FudiColors.primaryForeground
                : FudiColors.secondaryForeground,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
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
