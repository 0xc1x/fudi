import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/error/user_friendly_message.dart';
import '../../../core/ui/fudi_colors.dart';
import '../../../core/ui/fudi_spacing.dart';
import '../../../core/ui/fudi_typography.dart';
import '../../../core/ui/atoms/icons/fudi_icons.dart';
import '../../../core/ui/cards/business_card.dart';
import '../../../core/utils/geo_utils.dart';
import '../../../core/routing/route_names.dart';
import '../../offers/domain/offer.dart';
import '../../offers/presentation/offer_providers.dart';

class AllBusinessesScreen extends ConsumerStatefulWidget {
  const AllBusinessesScreen({super.key});

  @override
  ConsumerState<AllBusinessesScreen> createState() =>
      _AllBusinessesScreenState();
}

class _AllBusinessesScreenState extends ConsumerState<AllBusinessesScreen> {
  final _searchController = TextEditingController();
  Timer? _searchDebounce;
  String? _selectedType;

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filter = AllBusinessesFilter(
      searchQuery: _searchController.text.isNotEmpty
          ? _searchController.text
          : null,
      type: _selectedType,
    );
    final businessesAsync = ref.watch(allBusinessesProvider(filter));

    return Scaffold(
      backgroundColor: FudiColors.background,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _AllBusinessesHeader(
              searchController: _searchController,
              onSearchChanged: _onSearchChanged,
              onSubmitSearch: _submitSearch,
              selectedType: _selectedType,
              onTypeChanged: _onTypeChanged,
            ),
          ),
          businessesAsync.when(
            data: (businesses) => businesses.isEmpty
                ? const SliverFillRemaining(child: _EmptyState())
                : SliverPadding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: FudiSpacing.lg,
                      vertical: FudiSpacing.sm,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => Padding(
                          padding: const EdgeInsets.only(
                            bottom: FudiSpacing.md,
                          ),
                          child: _buildBusinessCard(context, businesses[index]),
                        ),
                        childCount: businesses.length,
                      ),
                    ),
                  ),
            loading: () => const SliverPadding(
              padding: EdgeInsets.symmetric(
                horizontal: FudiSpacing.lg,
                vertical: FudiSpacing.sm,
              ),
              sliver: SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(FudiSpacing.xl),
                    child: CircularProgressIndicator(),
                  ),
                ),
              ),
            ),
            error: (error, _) => SliverFillRemaining(
              child: _ErrorState(message: userFriendlyMessage(error)),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: FudiSpacing.xxl)),
        ],
      ),
    );
  }

  Widget _buildBusinessCard(BuildContext context, BusinessSummary business) {
    final distance = GeoUtils.formatDistance(
      business.latitude,
      business.longitude,
      userLat: ref.read(userLocationProvider).asData?.value?.latitude,
      userLng: ref.read(userLocationProvider).asData?.value?.longitude,
    );

    return BusinessCard(
      imageUrl: business.imageUrl ?? '',
      name: business.name,
      type: business.type,
      rating: business.rating,
      distance: distance,
      activeDealsCount: business.activeDealsCount,
      onTap: () =>
          context.push(RouteNames.businessProfileViewPath.replaceAll(
            ':id',
            business.id,
          )),
    );
  }

  void _onSearchChanged(String query) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 400), () {
      setState(() {});
    });
  }

  void _submitSearch(String query) {
    _searchDebounce?.cancel();
    setState(() {});
  }

  void _onTypeChanged(String? type) {
    setState(() => _selectedType = type);
  }
}

class _AllBusinessesHeader extends StatelessWidget {
  const _AllBusinessesHeader({
    required this.searchController,
    this.onSearchChanged,
    required this.onSubmitSearch,
    required this.selectedType,
    required this.onTypeChanged,
  });

  final TextEditingController searchController;
  final ValueChanged<String>? onSearchChanged;
  final ValueChanged<String> onSubmitSearch;
  final String? selectedType;
  final ValueChanged<String?> onTypeChanged;

  static const _businessTypes = [
    'Restaurante',
    'Café',
    'Panadería',
    'Supermercado',
    'Pastelería',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: FudiColors.background,
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
              children: [
                IconButton(
                  icon: const Icon(FudiIcons.chevronLeft),
                  onPressed: () => context.pop(),
                  color: FudiColors.foreground,
                ),
                Text(
                  'Negocios cerca',
                  style: FudiTypography.h1,
                ),
              ],
            ),
            const SizedBox(height: FudiSpacing.md),
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: searchController,
              builder: (context, value, _) => TextField(
                controller: searchController,
                onChanged: (query) => onSearchChanged?.call(query),
                onSubmitted: onSubmitSearch,
                decoration: InputDecoration(
                  hintText: 'Buscar negocios...',
                  hintStyle: FudiTypography.bodyMedium.copyWith(
                    color: FudiColors.mutedForeground,
                  ),
                  prefixIcon: const Icon(
                    FudiIcons.search,
                    color: FudiColors.mutedForeground,
                  ),
                  suffixIcon: value.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(
                            FudiIcons.x,
                            color: FudiColors.mutedForeground,
                          ),
                          onPressed: () {
                            searchController.clear();
                            onSubmitSearch('');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: FudiColors.card,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(FudiRadius.lg),
                    borderSide: BorderSide(
                      color: FudiColors.borderSolid,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: FudiSpacing.lg,
                    vertical: FudiSpacing.md,
                  ),
                ),
                style: FudiTypography.bodyMedium,
              ),
            ),
            const SizedBox(height: FudiSpacing.md),
            SizedBox(
              height: 36,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _businessTypes.length + 1,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return _TypeChip(
                      label: 'Todos',
                      isSelected: selectedType == null,
                      onTap: () => onTypeChanged(null),
                    );
                  }
                  final type = _businessTypes[index - 1];
                  return _TypeChip(
                    label: type,
                    isSelected: selectedType == type,
                    onTap: () => onTypeChanged(type),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  const _TypeChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: FudiSpacing.md,
          vertical: FudiSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? FudiColors.accent
              : FudiColors.muted.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(FudiRadius.full),
          border: Border.all(
            color: isSelected
                ? FudiColors.accent
                : FudiColors.accent.withValues(alpha: 0.15),
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: FudiTypography.bodySmall.copyWith(
              color: isSelected
                  ? FudiColors.accentForeground
                  : FudiColors.accent.withValues(alpha: 0.7),
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(FudiSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              FudiIcons.store,
              size: 48,
              color: FudiColors.mutedForeground,
            ),
            const SizedBox(height: FudiSpacing.md),
            Text(
              'No se encontraron negocios',
              style: FudiTypography.bodyMedium,
            ),
            const SizedBox(height: FudiSpacing.xs),
            Text(
              'Intenta cambiar los filtros o la búsqueda',
              style: FudiTypography.bodySmall,
            ),
          ],
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(FudiSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
