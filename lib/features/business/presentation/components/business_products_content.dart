import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/ui/fudi_colors.dart';
import '../../../../core/ui/fudi_empty_state.dart';
import '../../../../core/ui/fudi_pressable_scale.dart';
import '../../../../core/ui/fudi_spacing.dart';
import '../../../../core/ui/fudi_typography.dart';
import '../../../../core/ui/atoms/fudi_filter_chip.dart';
import '../../../../core/ui/atoms/icons/fudi_icons.dart';
import '../../../offers/domain/offer.dart';
import '../../domain/business_profile.dart';
import '../business_providers.dart';
import 'business_products_active_filters.dart';
import 'create_product_button.dart';
import 'product_card.dart';
import 'products_search_bar.dart';
import 'products_sort_button.dart';
import 'stats_row.dart';

class BusinessProductsContent extends ConsumerWidget {
  const BusinessProductsContent({
    super.key,
    required this.business,
    required this.allBusinesses,
    required this.offers,
    this.isLoading = false,
  });

  final BusinessProfile business;
  final List<BusinessProfile> allBusinesses;
  final List<Offer> offers;
  final bool isLoading;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeCount = offers.where((o) => o.isActive).length;
    final soldToday = offers.fold<int>(
      0,
      (sum, o) => sum + (o.initialStock - o.stock),
    );
    final availableCount = offers.fold<int>(0, (sum, o) => sum + o.stock);

    final filteredOffers =
        ref.watch(filteredBusinessOffersProvider(business.id));

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: StatsRow(
            activeCount: activeCount,
            soldToday: soldToday,
            availableCount: availableCount,
          ),
        ),
        SliverToBoxAdapter(
          child: CreateProductButton(
            onTap: () => context.push('/business/products/create'),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              FudiSpacing.lg,
              FudiSpacing.md,
              FudiSpacing.lg,
              FudiSpacing.sm,
            ),
            child: Row(
              children: [
                Text('Todos los productos', style: FudiTypography.h4),
                const Spacer(),
                const ProductsSortButton(),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              FudiSpacing.lg,
              0,
              FudiSpacing.lg,
              FudiSpacing.sm,
            ),
            child: Row(
              children: [
                const Expanded(child: ProductsSearchBar()),
                const SizedBox(width: FudiSpacing.sm),
                const BusinessProductsActiveFilters(),
              ],
            ),
          ),
        ),
        const SliverToBoxAdapter(child: _ActiveFiltersChipsRow()),
        if (isLoading)
          const SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(FudiSpacing.xl),
                child: CircularProgressIndicator(),
              ),
            ),
          )
        else if (filteredOffers.isEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: FudiSpacing.xl),
              child: FudiEmptyState(
                icon: FudiIcons.package_,
                title: 'No tienes productos publicados',
                description: '',
                actionLabel: 'Crear mi primer producto',
                onAction: () => context.push('/business/products/create'),
              ),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: FudiSpacing.lg),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => Padding(
                  padding: const EdgeInsets.only(bottom: FudiSpacing.md),
                  child: ProductCard(offer: filteredOffers[index]),
                ),
                childCount: filteredOffers.length,
              ),
            ),
          ),
        const SliverToBoxAdapter(child: SizedBox(height: FudiSpacing.xxl)),
      ],
    );
  }
}

class _ActiveFiltersChipsRow extends ConsumerWidget {
  const _ActiveFiltersChipsRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final category = ref.watch(productsCategoryFilterProvider);
    if (category == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        FudiSpacing.lg,
        FudiSpacing.sm,
        FudiSpacing.lg,
        FudiSpacing.sm,
      ),
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _ActiveChip(
                    label: category.dbValue,
                    onClear: () => ref
                        .read(productsCategoryFilterProvider.notifier)
                        .select(null),
                  ),
                ],
              ),
            ),
          ),
          FudiPressableScale(
            onTap: () {
              ref.read(productsCategoryFilterProvider.notifier).select(null);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: FudiSpacing.sm,
                vertical: FudiSpacing.xs,
              ),
              child: Text(
                'Limpiar',
                style: FudiTypography.bodySmall.copyWith(
                  color: FudiColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActiveChip extends StatelessWidget {
  const _ActiveChip({required this.label, required this.onClear});

  final String label;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return FudiFilterChip(label: label, onClear: onClear);
  }
}
