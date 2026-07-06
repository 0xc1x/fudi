import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/ui/fudi_colors.dart';
import '../../../core/ui/fudi_spacing.dart';
import '../../../core/ui/fudi_typography.dart';
import '../../../core/ui/fudi_sticky_page_header.dart';
import '../../../core/ui/fudi_surface_card.dart';
import '../../../core/ui/fudi_pressable_scale.dart';
import '../../../core/ui/fudi_theme.dart';
import '../../../core/ui/theme_notifier.dart';
import '../domain/consumer_preferences.dart';
import 'profile_providers.dart';

class GeneralSettingsScreen extends ConsumerWidget {
  const GeneralSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefsAsync = ref.watch(consumerPreferencesProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const FudiStickyPageHeader(title: 'Configuración'),
      body: prefsAsync.when(
        data: (prefs) => _buildContent(context, ref, prefs),
        loading: () => Center(
          child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary),
        ),
        error: (error, _) => Center(
          child: Text(
            'Error al cargar configuración: $error',
            style: FudiTypography.bodyMedium.copyWith(
              color: Theme.of(context).colorScheme.error,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    ConsumerPreferences prefs,
  ) {
    final themeState = ref.watch(themeNotifierProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final themeExt = theme.extension<FudiThemeExtension>();

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(
        horizontal: FudiSpacing.xl,
        vertical: FudiSpacing.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sección: Apariencia
          Text(
            'Apariencia',
            style: FudiTypography.labelSmall.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: FudiSpacing.md),
          Row(
            children: [
              Expanded(
                child: _ThemeOptionCard(
                  title: 'Claro',
                  icon: Icons.light_mode_rounded,
                  isSelected: themeState == AppThemeMode.light,
                  onTap: () => ref.read(themeNotifierProvider.notifier).setThemeMode(AppThemeMode.light),
                ),
              ),
              const SizedBox(width: FudiSpacing.sm),
              Expanded(
                child: _ThemeOptionCard(
                  title: 'Oscuro',
                  icon: Icons.dark_mode_rounded,
                  isSelected: themeState == AppThemeMode.dark,
                  onTap: () => ref.read(themeNotifierProvider.notifier).setThemeMode(AppThemeMode.dark),
                ),
              ),
              const SizedBox(width: FudiSpacing.sm),
              Expanded(
                child: _ThemeOptionCard(
                  title: 'Sistema',
                  icon: Icons.brightness_auto_rounded,
                  isSelected: themeState == AppThemeMode.system,
                  onTap: () => ref.read(themeNotifierProvider.notifier).setThemeMode(AppThemeMode.system),
                ),
              ),
            ],
          ),

          const SizedBox(height: FudiSpacing.xl),

          // Sección: Radio de Búsqueda
          Text(
            'Radio de búsqueda',
            style: FudiTypography.labelSmall.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: FudiSpacing.md),
          FudiSurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Distancia máxima',
                      style: FudiTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${prefs.notificationRadiusKm} km',
                        style: FudiTypography.labelSmall.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: FudiSpacing.sm),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: theme.colorScheme.primary,
                    inactiveTrackColor: themeExt?.mutedBackground ?? (isDark ? FudiColorsDark.muted : FudiColors.muted),
                    thumbColor: theme.colorScheme.primary,
                    overlayColor: theme.colorScheme.primary.withValues(alpha: 0.12),
                    trackHeight: 4,
                  ),
                  child: Slider(
                    value: prefs.notificationRadiusKm.toDouble(),
                    min: 1,
                    max: 50,
                    divisions: 49,
                    onChanged: (v) => _update(
                      ref,
                      prefs.copyWith(notificationRadiusKm: v.round()),
                    ),
                  ),
                ),
                Text(
                  'Te mostraremos ofertas gastronómicas y comerciales dentro de este radio de cobertura.',
                  style: FudiTypography.bodySmall.copyWith(
                    color: isDark ? FudiColorsDark.mutedForeground : FudiColors.mutedForeground,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: FudiSpacing.xl),

          // Sección: Idioma
          Text(
            'Idioma',
            style: FudiTypography.labelSmall.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: FudiSpacing.md),
          FudiPressableScale(
            onTap: () => _showLanguagePicker(context, ref, prefs),
            child: FudiSurfaceCard(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Idioma de la app',
                        style: FudiTypography.bodyMedium.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        prefs.language == 'es' ? 'Español' : 'Inglés (English)',
                        style: FudiTypography.bodySmall.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Icon(
                    Icons.keyboard_arrow_right_rounded,
                    color: isDark ? FudiColorsDark.mutedForeground : FudiColors.mutedForeground,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Actualización optimizada con feedback instantáneo en UI
  void _update(WidgetRef ref, ConsumerPreferences prefs) async {
    await ref.read(consumerProfileRepositoryProvider).updatePreferences(prefs);
    ref.invalidate(consumerPreferencesProvider);
  }

  // Modal Inferior Custom de Fudi para selección de idioma
  void _showLanguagePicker(
    BuildContext context,
    WidgetRef ref,
    ConsumerPreferences prefs,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final themeExt = theme.extension<FudiThemeExtension>();

    unawaited(showModalBottomSheet(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(FudiSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 38,
                    height: 4,
                    decoration: BoxDecoration(
                      color: themeExt?.mutedBackground ?? (isDark ? FudiColorsDark.muted : FudiColors.muted),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: FudiSpacing.lg),
                Text(
                  'Selecciona tu idioma',
                  style: FudiTypography.h3.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: FudiSpacing.lg),
                _LanguageOption(
                  label: 'Español',
                  isSelected: prefs.language == 'es',
                  onTap: () {
                    _update(ref, prefs.copyWith(language: 'es'));
                    Navigator.pop(context);
                  },
                ),
                const SizedBox(height: FudiSpacing.sm),
                _LanguageOption(
                  label: 'Inglés (English)',
                  isSelected: prefs.language == 'en',
                  onTap: () {
                    _update(ref, prefs.copyWith(language: 'en'));
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    ));
  }
}

// Sub-componente privado para las tarjetas de selección de tema
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
              : (themeExt?.cardBg ?? (isDark ? FudiColorsDark.muted : FudiColors.card)),
          borderRadius: BorderRadius.circular(FudiRadius.md),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : (themeExt?.border ?? (isDark ? FudiColorsDark.border : FudiColors.borderSolid)),
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            const SizedBox(height: FudiSpacing.xs),
            Text(
              title,
              style: FudiTypography.bodySmall.copyWith(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Sub-componente privado para las opciones del selector de idioma
class _LanguageOption extends StatelessWidget {
  const _LanguageOption({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeExt = theme.extension<FudiThemeExtension>();

    return FudiPressableScale(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(FudiSpacing.lg),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary.withValues(alpha: 0.05)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary.withValues(alpha: 0.3)
                : (themeExt?.borderSolid ?? FudiColors.borderSolid),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: FudiTypography.bodyMedium.copyWith(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w400,
                color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface,
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle_rounded,
                color: theme.colorScheme.primary,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}
