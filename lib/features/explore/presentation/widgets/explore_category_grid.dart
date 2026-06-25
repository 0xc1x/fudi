import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/ui/fudi_colors.dart';
import '../../../../core/ui/fudi_pressable_scale.dart';
import '../../../../core/ui/fudi_spacing.dart';
import '../../../../core/ui/fudi_typography.dart';
import '../../../../core/ui/atoms/icons/fudi_icons.dart';
import '../../../../core/ui/fudi_info_chips_bar.dart';
import '../../../offers/domain/offer_category.dart';
import '../../../offers/domain/offer_repository.dart';
import '../../../offers/presentation/offer_providers.dart';

class ExploreCategoryGrid extends ConsumerStatefulWidget {
  const ExploreCategoryGrid({
    super.key,
    required this.stats,
    required this.selectedCategory,
    required this.onCategoryTap,
  });

  final List<CategoryStat> stats;
  final OfferCategory? selectedCategory;
  final ValueChanged<String> onCategoryTap;

  @override
  ConsumerState<ExploreCategoryGrid> createState() =>
      _ExploreCategoryGridState();
}

class _ExploreCategoryGridState extends ConsumerState<ExploreCategoryGrid> {
  bool _showAll = false;
  static const _initialCount = 5;
  static const _animDuration = Duration(milliseconds: 300);

  // IDs que ya estaban visibles en el frame anterior.
  // Los que NO estén aquí son "nuevos" y deben animarse.
  // Tipo explícito <String> necesario para que .difference() funcione en web.
  final Set<String> _visibleIds = <String>{};

  @override
  Widget build(BuildContext context) {
    if (widget.stats.isEmpty) return const SizedBox.shrink();

    final display = _showAll
        ? widget.stats
        : widget.stats.take(_initialCount).toList();
    final remaining = widget.stats.length - _initialCount;

    // IDs que vamos a mostrar este frame — tipo explícito por la misma razón.
    final Set<String> currentIds = <String>{
      ...display.map((c) => c.id),
      if (!_showAll && remaining > 0) '__expand__',
      if (_showAll && widget.stats.length > _initialCount) '__collapse__',
    };

    // Los que no estaban antes → entran animados
    final Set<String> newIds = currentIds.difference(_visibleIds);

    // Actualizamos el set para el próximo frame
    // (lo hacemos después del build con addPostFrameCallback para no
    //  mutar estado durante el build)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _visibleIds
          ..clear()
          ..addAll(currentIds);
        // No llamamos setState aquí — _visibleIds es solo
        // un registro interno, no necesita rebuild.
      }
    });

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        FudiSpacing.lg,
        FudiSpacing.lg,
        FudiSpacing.lg,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ExplorPopularAreasSection(),
          const SizedBox(height: FudiSpacing.lg),
          Text('Categorías', style: FudiTypography.headlineSmall),
          const SizedBox(height: FudiSpacing.md),
          LayoutBuilder(
            builder: (context, constraints) {
              final cellWidth = (constraints.maxWidth - FudiSpacing.sm) / 2;

              return AnimatedSize(
                duration: _animDuration,
                curve: Curves.easeInOutCubic,
                alignment: Alignment.topCenter,
                child: Wrap(
                  spacing: FudiSpacing.sm,
                  runSpacing: FudiSpacing.sm,
                  children: [
                    ...display.map((cat) {
                      final isSelected =
                          widget.selectedCategory?.dbValue == cat.id;
                      final isNew = newIds.contains(cat.id);
                      return _FadeSlideIn(
                        key: ValueKey(cat.id),
                        width: cellWidth,
                        animate: isNew,
                        duration: _animDuration,
                        child: ExploreCategoryCard(
                          imageUrl: cat.imageUrl,
                          name: cat.name,
                          count: cat.count,
                          isSelected: isSelected,
                          onTap: () => widget.onCategoryTap(cat.id),
                        ),
                      );
                    }),
                    if (!_showAll && remaining > 0)
                      _FadeSlideIn(
                        key: const ValueKey('__expand__'),
                        width: cellWidth,
                        animate: newIds.contains('__expand__'),
                        duration: _animDuration,
                        child: ExploreExpandCard(
                          remaining: remaining,
                          icon: FudiIcons.chevronDown,
                          label: 'Ver más categorías',
                          onTap: () => setState(() => _showAll = true),
                        ),
                      ),
                    if (_showAll && widget.stats.length > _initialCount)
                      _FadeSlideIn(
                        key: const ValueKey('__collapse__'),
                        width: cellWidth,
                        animate: newIds.contains('__collapse__'),
                        duration: _animDuration,
                        child: ExploreExpandCard(
                          remaining: 0,
                          icon: FudiIcons.chevronUp,
                          label: 'Ver menos',
                          onTap: () => setState(() => _showAll = false),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ── Widget de entrada animada ─────────────────────────────────────────────────
//
// Usa TweenAnimationBuilder para que la animación arranque
// INMEDIATAMENTE en el primer build, sin depender de postFrameCallback.
// Si animate == false el widget aparece directamente en su estado final.

class _FadeSlideIn extends StatelessWidget {
  const _FadeSlideIn({
    super.key,
    required this.width,
    required this.animate,
    required this.duration,
    required this.child,
  });

  final double width;
  final bool animate;
  final Duration duration;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!animate) {
      return SizedBox(width: width, child: child);
    }

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            // Sube 10px mientras aparece → sensación de "emerge"
            offset: Offset(0, 10 * (1 - value)),
            child: child,
          ),
        );
      },
      child: SizedBox(width: width, child: child),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Widgets sin cambios
// ─────────────────────────────────────────────────────────────────────────────

class ExplorPopularAreasSection extends ConsumerWidget {
  const ExplorPopularAreasSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final areasAsync = ref.watch(popularAreasProvider);

    return areasAsync.when(
      data: (areas) {
        if (areas.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Áreas Populares', style: FudiTypography.headlineSmall),
            const SizedBox(height: FudiSpacing.md),
            FudiInfoChipsBar(
              padding: EdgeInsets.zero,
              items: areas
                  .map(
                    (area) => FudiInfoChipItem(
                      label: area.name,
                      icon: FudiIcons.mapPin,
                      count: area.deals,
                    ),
                  )
                  .toList(),
            ),
          ],
        );
      },
      error: (_, _) => const SizedBox.shrink(),
      loading: () => const SizedBox.shrink(),
    );
  }
}

class ExploreCategoryCard extends StatelessWidget {
  const ExploreCategoryCard({
    super.key,
    required this.imageUrl,
    required this.name,
    required this.count,
    required this.isSelected,
    required this.onTap,
  });

  final String imageUrl;
  final String name;
  final int count;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color cardBackground = isSelected
        ? FudiColors.primary.withValues(alpha: 0.2)
        : FudiColors.card;

    return FudiPressableScale(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 85,
        decoration: BoxDecoration(
          color: cardBackground,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFFFF4B4B) : FudiColors.border,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFFFF4B4B).withValues(alpha: 0.15),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                width: 100,
                child: ShaderMask(
                  shaderCallback: (rect) {
                    return const LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [Colors.transparent, Colors.black],
                      stops: [0.0, 0.4],
                    ).createShader(
                      Rect.fromLTRB(0, 0, rect.width, rect.height),
                    );
                  },
                  blendMode: BlendMode.dstIn,
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    alignment: Alignment.centerLeft,
                    errorBuilder: (context, error, stackTrace) =>
                        Container(color: const Color(0xFF1E2022)),
                  ),
                ),
              ),
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.only(left: 16.0, right: 90.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        name,
                        style: FudiTypography.h2.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '$count ofertas',
                        style: FudiTypography.bodySmall.copyWith(
                          color: FudiColors.mutedForeground,
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
    );
  }
}

class ExploreExpandCard extends StatelessWidget {
  const ExploreExpandCard({
    super.key,
    required this.remaining,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final int remaining;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FudiPressableScale(
      onTap: onTap,
      child: Container(
        height: 85,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        decoration: BoxDecoration(
          color: FudiColors.card,
          borderRadius: BorderRadius.circular(FudiRadius.lg),
          border: Border.all(color: FudiColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: FudiColors.mutedForeground.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 22, color: FudiColors.mutedForeground),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    label,
                    style: FudiTypography.bodySmall.copyWith(
                      fontWeight: FontWeight.w700,
                      color: FudiColors.mutedForeground,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (remaining > 0) ...[
                    const SizedBox(height: 4),
                    Text(
                      '+$remaining categorías',
                      style: FudiTypography.bodySmall.copyWith(
                        color: FudiColors.mutedForeground.withValues(
                          alpha: 0.6,
                        ),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: FudiColors.mutedForeground.withValues(alpha: 0.4),
            ),
          ],
        ),
      ),
    );
  }
}
