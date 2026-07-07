import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/route_names.dart';
import '../../../core/ui/fudi_colors.dart';
import '../../../core/ui/fudi_pressable_scale.dart';
import '../../../core/ui/fudi_theme.dart';
import '../../../core/ui/fudi_typography.dart';
import '../../../core/ui/theme_notifier.dart';
import '../../../core/ui/atoms/icons/fudi_icons.dart';
import '../../../core/ui/fudi_spacing.dart';
import '../../../core/ui/fudi_surface_card.dart';
import 'business_providers.dart';
import 'components/no_business_prompt.dart';

class BusinessManagementProfileScreen extends ConsumerWidget {
  const BusinessManagementProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final themeExt = theme.extension<FudiThemeExtension>();
    final businessAsync = ref.watch(currentBusinessProvider);
    return Scaffold(
      backgroundColor: themeExt?.mutedBackground ?? FudiColors.muted,
      appBar: AppBar(
        title: const Text('Perfil de Negocio', style: FudiTypography.h4),
      ),
      body: businessAsync.when(
        data: (business) {
          if (business == null) return const NoBusinessPrompt();
          return ListView(
            padding: const EdgeInsets.all(FudiSpacing.lg),
            children: [
              FudiSurfaceCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(business.name, style: FudiTypography.h2),
                    const SizedBox(height: FudiSpacing.xs),
                    Text(business.type, style: FudiTypography.bodySmall),
                    const SizedBox(height: FudiSpacing.md),
                    Text(
                      business.description ?? 'Sin descripción registrada',
                      style: FudiTypography.bodyMedium,
                    ),
                    const SizedBox(height: FudiSpacing.md),
                    FilledButton.icon(
                      onPressed: () =>
                          context.push(RouteNames.businessEditPath),
                      icon: const Icon(Icons.edit_rounded),
                      label: const Text('Editar perfil'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: FudiSpacing.md),
              FudiSurfaceCard(
                padding: const EdgeInsets.all(FudiSpacing.md),
                child: Column(
                  children: [
                    _Info(
                      icon: FudiIcons.mapPin,
                      value: business.address ?? '',
                    ),
                    if (business.phone != null)
                      _Info(icon: FudiIcons.phone, value: business.phone!),
                    if (business.email != null)
                      _Info(icon: FudiIcons.mail, value: business.email!),
                  ],
                ),
              ),
              const SizedBox(height: FudiSpacing.xl),
              Text(
                'Apariencia',
                style: FudiTypography.labelSmall.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: FudiSpacing.md),
              _ThemeRow(),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
      ),
    );
  }
}

class _Info extends StatelessWidget {
  const _Info({required this.icon, required this.value});
  final IconData icon;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: FudiSpacing.sm),
      child: Row(
        children: [
          Icon(icon, size: 18, color: FudiColors.primary),
          const SizedBox(width: FudiSpacing.sm),
          Expanded(child: Text(value, style: FudiTypography.bodyMedium)),
        ],
      ),
    );
  }
}

class _ThemeRow extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeNotifierProvider);

    return Row(
      children: [
        Expanded(
          child: _ThemeOptionCard(
            title: 'Claro',
            icon: Icons.light_mode_rounded,
            isSelected: themeState == AppThemeMode.light,
            onTap: () => ref
                .read(themeNotifierProvider.notifier)
                .setThemeMode(AppThemeMode.light),
          ),
        ),
        const SizedBox(width: FudiSpacing.sm),
        Expanded(
          child: _ThemeOptionCard(
            title: 'Oscuro',
            icon: Icons.dark_mode_rounded,
            isSelected: themeState == AppThemeMode.dark,
            onTap: () => ref
                .read(themeNotifierProvider.notifier)
                .setThemeMode(AppThemeMode.dark),
          ),
        ),
        const SizedBox(width: FudiSpacing.sm),
        Expanded(
          child: _ThemeOptionCard(
            title: 'Sistema',
            icon: Icons.brightness_auto_rounded,
            isSelected: themeState == AppThemeMode.system,
            onTap: () => ref
                .read(themeNotifierProvider.notifier)
                .setThemeMode(AppThemeMode.system),
          ),
        ),
      ],
    );
  }
}

class _ThemeOptionCard extends StatelessWidget {
  const _ThemeOptionCard({
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final themeExt = theme.extension<FudiThemeExtension>();

    return FudiPressableScale(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: FudiSpacing.md),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary.withValues(alpha: isDark ? 0.15 : 0.05)
              : (themeExt?.cardBg ??
                  (isDark ? FudiColorsDark.muted : FudiColors.card)),
          borderRadius: BorderRadius.circular(FudiRadius.md),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : (themeExt?.border ??
                    (isDark
                        ? FudiColorsDark.border
                        : FudiColors.borderSolid)),
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            const SizedBox(height: FudiSpacing.xs),
            Text(
              title,
              style: FudiTypography.bodySmall.copyWith(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
