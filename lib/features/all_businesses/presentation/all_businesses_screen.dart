import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/error/user_friendly_message.dart';
import '../../../core/ui/fudi_colors.dart';
import '../../../core/ui/fudi_pressable_scale.dart';
import '../../../core/ui/fudi_spacing.dart';
import '../../../core/ui/fudi_typography.dart';
import '../../../core/ui/atoms/icons/fudi_icons.dart';
import '../../../core/ui/cards/business_card.dart';
import '../../../core/ui/fudi_selectable_chips_bar.dart';
import '../../../core/ui/fudi_search_bar.dart';
import '../../../core/ui/fudi_empty_state.dart';
import '../../../core/ui/fudi_error_state.dart';
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
                ? const SliverFillRemaining(
                    child: FudiEmptyState(
                      title: 'No se encontraron negocios',
                      description: 'Intenta cambiar los filtros o la búsqueda',
                      icon: FudiIcons.store,
                    ),
                  )
                : SliverPadding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: FudiSpacing.lg,
                      vertical: FudiSpacing.sm,
                    ),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            mainAxisSpacing: FudiSpacing.md,
                            crossAxisSpacing: FudiSpacing.md,
                            mainAxisExtent: 240,
                          ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) =>
                            _buildBusinessCard(context, businesses[index]),
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
              child: FudiErrorState(message: userFriendlyMessage(error)),
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
      onTap: () => context.push(
        RouteNames.businessProfileViewPath.replaceAll(':id', business.id),
      ),
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
                FudiPressableScale(
                  onTap: () => context.pop(),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(shape: BoxShape.circle),
                    child: const Icon(FudiIcons.chevronLeft, color: FudiColors.foreground),
                  ),
                ),
                Text('Negocios cerca', style: FudiTypography.h1),
              ],
            ),
            FudiSearchBar(
              controller: searchController,
              hintText: 'Buscar negocios...',
              onChanged: onSearchChanged,
              onSubmitted: onSubmitSearch,
            ),
            const SizedBox(height: FudiSpacing.md),
            FudiSelectableChipsBar<String?>(
              items: const [null, ..._businessTypes],
              selectedItem: selectedType,
              labelBuilder: (type) => type ?? 'Todos',
              onSelected: (type) => onTypeChanged(type),
              height: 40,
              padding: EdgeInsets.zero,
              horizontalChipPadding: FudiSpacing.lg,
            ),
          ],
        ),
      ),
    );
  }
}

