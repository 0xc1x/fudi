import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/error/user_friendly_message.dart';
import '../../../core/routing/route_names.dart';
import '../../../core/ui/fudi_logo.dart';
import '../../../core/ui/fudi_colors.dart';
import '../../../core/ui/atoms/icons/fudi_icons.dart';
import '../../../core/ui/fudi_spacing.dart';
import '../../../core/ui/fudi_typography.dart';
import '../../offers/domain/offer_repository.dart';
import '../../../core/ui/fudi_selectable_chips_bar.dart';
import '../../../core/ui/fudi_error_state.dart';
import '../../offers/domain/offer_category.dart';
import '../../offers/presentation/offer_providers.dart';

// Nuevos widgets extraídos
import 'widgets/location_selector.dart';
import 'widgets/welcome_banner.dart';
import 'widgets/promo_slider.dart';
import 'widgets/eco_banner.dart';
import 'widgets/offer_sections.dart';
import 'widgets/business_sections.dart';

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
    final statsAsync = ref.watch(categoryStatsProvider);
    final expiringAsync = ref.watch(expiringSoonOffersProvider);
    final recentAsync = ref.watch(recentOffersProvider);
    final businessesAsync = ref.watch(nearbyBusinessesProvider);

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
            const SliverToBoxAdapter(child: WelcomeBanner()),

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
            const SliverToBoxAdapter(child: PromoSlider()),

            // ── Últimas Horas ────────────────────────────────────────
            expiringAsync.when(
              data: (offers) => offers.isEmpty
                  ? const SliverToBoxAdapter(child: SizedBox.shrink())
                  : SliverToBoxAdapter(
                      child: OfferRowSection(
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
                      child: OfferRowSection(
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
                      child: OfferRowSection(
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
                  const SliverToBoxAdapter(child: PopularLoadingSkeleton()),
              error: (error, _) => SliverToBoxAdapter(
                child: FudiErrorState(message: userFriendlyMessage(error)),
              ),
            ),

            // ── Eco Banner ───────────────────────────────────────────
            const SliverToBoxAdapter(child: EcoBanner()),

            // ── Negocios Cerca ───────────────────────────────────────
            businessesAsync.when(
              data: (businesses) => businesses.isEmpty
                  ? const SliverToBoxAdapter(child: SizedBox.shrink())
                  : SliverToBoxAdapter(
                      child: BusinessesRowSection(
                        businesses: businesses,
                        onSeeAll: () =>
                            context.push(RouteNames.allBusinessesPath),
                      ),
                    ),
              loading: () => const SliverToBoxAdapter(child: SizedBox.shrink()),
              error: (_, _) =>
                  const SliverToBoxAdapter(child: SizedBox.shrink()),
            ),

            // ── Cerca de Ti (Aislado para evitar parpadeos generales) ──
            const _NearbyOffersSection(),

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
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: FudiColors.background,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      title: const LocationSelector(),
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
    final allStats = [
      const CategoryStat(
        id: 'all',
        name: 'Todos',
        count: 0,
        emoji: '',
        imageUrl: '',
      ),
      ...stats,
    ];

    final selectedItem = allStats.firstWhere(
      (c) => (c.id == 'all' ? null : c.id) == selectedCategoryId,
      orElse: () => allStats.first,
    );

    return Container(
      color: FudiColors.background,
      padding: const EdgeInsets.symmetric(vertical: FudiSpacing.md),
      child: FudiSelectableChipsBar<CategoryStat>(
        items: allStats,
        selectedItem: selectedItem,
        labelBuilder: (c) => c.name,
        onSelected: (c) {
          final catId = c.id == 'all' ? null : c.id;
          onSelected(catId);
        },
        initialCount: 5,
        activeColor: FudiColors.greenDark,
        activeTextColor: FudiColors.green,
        inactiveColor: FudiColors.green.withValues(alpha: 0.3),
        inactiveTextColor: FudiColors.greenDark.withValues(alpha: 0.7),
        borderColor: FudiColors.greenDark.withValues(alpha: 0.15),
        borderRadius: FudiRadius.md,
        height: 40.0,
        horizontalChipPadding: FudiSpacing.lg,
      ),
    );
  }
}

// ── Sección Cerca de Ti Enmascarada en un ConsumerWidget Independiente ───

class _NearbyOffersSection extends ConsumerWidget {
  const _NearbyOffersSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // El ref.watch de la ubicación vive únicamente aquí adentro.
    final locationAsync = ref.watch(selectedDiscoveryLocationProvider);
    final nearbyAsync = ref.watch(nearbyOffersProvider);

    final hasLocation =
        locationAsync.whenOrNull(
          data: (position) => position != null,
          error: (_, _) => false,
        ) ??
        false;

    if (!hasLocation) {
      return const SliverToBoxAdapter(child: _LocationPrompt());
    }

    return nearbyAsync.when(
      data: (offers) => offers.isEmpty
          ? const SliverToBoxAdapter(child: SizedBox.shrink())
          : SliverToBoxAdapter(
              child: OfferColumnSection(
                title: 'Cerca de Ti',
                offers: offers,
                onSeeAll: () => context.push(
                  RouteNames.allOffersPath,
                  extra: AllOffersView.nearby,
                ),
              ),
            ),
      loading: () => SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: FudiSpacing.lg),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (_, _) => const DealCardSkeleton(),
            childCount: 3,
          ),
        ),
      ),
      error: (error, _) => SliverToBoxAdapter(
        child: FudiErrorState(message: userFriendlyMessage(error)),
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
