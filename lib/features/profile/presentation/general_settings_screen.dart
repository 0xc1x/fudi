import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/ui/fudi_colors.dart';
import '../../../core/ui/fudi_spacing.dart';
import '../../../core/ui/fudi_typography.dart';
import '../../../core/ui/fudi_sticky_page_header.dart';
import '../../../core/ui/fudi_surface_card.dart';
import '../../../core/ui/fudi_pressable_scale.dart';
import '../domain/consumer_preferences.dart';
import 'profile_providers.dart';

class GeneralSettingsScreen extends ConsumerWidget {
  const GeneralSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefsAsync = ref.watch(consumerPreferencesProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const FudiStickyPageHeader(title: 'Configuración'),
      body: prefsAsync.when(
        data: (prefs) => _buildContent(context, ref, prefs),
        loading: () => const Center(
          child: CircularProgressIndicator(color: FudiColors.primary),
        ),
        error: (error, _) => Center(
          child: Text(
            'Error al cargar configuración: $error',
            style: FudiTypography.bodyMedium.copyWith(
              color: FudiColors.destructive,
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
          FudiSurfaceCard(
            padding: const EdgeInsets.symmetric(
              horizontal: FudiSpacing.md,
              vertical: FudiSpacing.xs,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Modo Oscuro',
                        style: FudiTypography.bodyMedium.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        'Cambiar el tema visual de la aplicación',
                        style: FudiTypography.bodySmall.copyWith(
                          color: FudiColors.mutedForeground,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch.adaptive(
                  value: prefs.darkMode,
                  activeThumbColor: FudiColors.primary,
                  activeTrackColor: FudiColors.primary.withValues(alpha: 0.2),
                  onChanged: (v) => _update(ref, prefs.copyWith(darkMode: v)),
                ),
              ],
            ),
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
                        color: FudiColors.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${prefs.notificationRadiusKm} km',
                        style: FudiTypography.labelSmall.copyWith(
                          color: FudiColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: FudiSpacing.sm),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: FudiColors.primary,
                    inactiveTrackColor: FudiColors.inputBackground,
                    thumbColor: FudiColors.primary,
                    overlayColor: FudiColors.primary.withValues(alpha: 0.12),
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
                    color: FudiColors.mutedForeground,
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
                          color: FudiColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const Icon(
                    Icons.keyboard_arrow_right_rounded,
                    color: FudiColors.mutedForeground,
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
    // 1. Alternativa recomendada: Si usas un StateNotifier o AsyncNotifier en tu provider,
    // actualiza primero el estado en memoria para que la respuesta de sliders/switches sea inmediata.
    // Aquí invocamos directamente al repositorio y refrescamos:
    await ref.read(consumerProfileRepositoryProvider).updatePreferences(prefs);
    ref.invalidate(consumerPreferencesProvider);
  }

  // Modal Inferior Custom de Fudi para selección de idioma
  void _showLanguagePicker(
    BuildContext context,
    WidgetRef ref,
    ConsumerPreferences prefs,
  ) {
    unawaited(showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
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
                      color: FudiColors.inputBackground,
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
    return FudiPressableScale(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(FudiSpacing.lg),
        decoration: BoxDecoration(
          color: isSelected
              ? FudiColors.primary.withValues(alpha: 0.05)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? FudiColors.primary.withValues(alpha: 0.3)
                : FudiColors.borderSolid,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: FudiTypography.bodyMedium.copyWith(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w400,
                color: isSelected ? FudiColors.primary : FudiColors.foreground,
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle_rounded,
                color: FudiColors.primary,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}
