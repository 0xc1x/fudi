import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/ui/fudi_colors.dart';
import '../../../core/ui/fudi_spacing.dart';
import '../../../core/ui/fudi_typography.dart';
import '../../../core/ui/fudi_sticky_page_header.dart';
import '../../../core/ui/fudi_surface_card.dart';
import '../domain/consumer_preferences.dart';
import 'profile_providers.dart';

class GeneralSettingsScreen extends ConsumerWidget {
  const GeneralSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefsAsync = ref.watch(consumerPreferencesProvider);

    return Scaffold(
      appBar: const FudiStickyPageHeader(title: 'Configuración'),
      body: prefsAsync.when(
        data: (prefs) => _buildContent(ref, prefs),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildContent(WidgetRef ref, ConsumerPreferences prefs) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(FudiSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Apariencia', style: FudiTypography.labelMedium),
          const SizedBox(height: FudiSpacing.md),
          FudiSurfaceCard(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Modo Oscuro'),
                  subtitle: const Text('Cambiar el tema de la aplicación'),
                  value: prefs.darkMode,
                  onChanged: (v) => _update(ref, prefs.copyWith(darkMode: v)),
                  activeTrackColor: FudiColors.primary.withValues(alpha: 0.5),
                  activeThumbColor: FudiColors.primary,
                ),
              ],
            ),
          ),
          const SizedBox(height: FudiSpacing.xl),
          Text('Radio de búsqueda', style: FudiTypography.labelMedium),
          const SizedBox(height: FudiSpacing.md),
          FudiSurfaceCard(
            child: Padding(
              padding: const EdgeInsets.all(FudiSpacing.md),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Distancia máxima'),
                      Text('${prefs.notificationRadiusKm} km', style: FudiTypography.labelSmall.copyWith(color: FudiColors.primary)),
                    ],
                  ),
                  Slider(
                    value: prefs.notificationRadiusKm.toDouble(),
                    min: 1,
                    max: 50,
                    divisions: 49,
                    activeColor: FudiColors.primary,
                    onChanged: (v) => _update(ref, prefs.copyWith(notificationRadiusKm: v.round())),
                  ),
                  Text(
                    'Te mostraremos ofertas dentro de este radio.',
                    style: FudiTypography.bodySmall.copyWith(color: FudiColors.mutedForeground),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: FudiSpacing.xl),
          Text('Idioma', style: FudiTypography.labelMedium),
          const SizedBox(height: FudiSpacing.md),
          FudiSurfaceCard(
            child: ListTile(
              title: const Text('Idioma de la app'),
              subtitle: Text(prefs.language == 'es' ? 'Español' : 'Inglés'),
              trailing: const Icon(Icons.language, color: FudiColors.primary),
              onTap: () => _showLanguagePicker(ref, prefs),
            ),
          ),
        ],
      ),
    );
  }

  void _update(WidgetRef ref, ConsumerPreferences prefs) {
    ref.read(consumerProfileRepositoryProvider).updatePreferences(prefs);
    ref.invalidate(consumerPreferencesProvider);
  }

  void _showLanguagePicker(WidgetRef ref, ConsumerPreferences prefs) {
    // Implement language picker
  }
}
