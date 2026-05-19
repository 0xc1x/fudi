import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/ui/fudi_colors.dart';
import '../../../core/ui/fudi_spacing.dart';
import '../../../core/ui/fudi_typography.dart';
import '../../../core/ui/fudi_sticky_page_header.dart';
import '../../../core/ui/fudi_surface_card.dart';
import '../domain/consumer_preferences.dart';
import 'profile_providers.dart';

class NotificationSettingsScreen extends ConsumerWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefsAsync = ref.watch(consumerPreferencesProvider);

    return Scaffold(
      appBar: const FudiStickyPageHeader(title: 'Notificaciones'),
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
          Text('Canales de comunicación', style: FudiTypography.labelMedium),
          const SizedBox(height: FudiSpacing.md),
          FudiSurfaceCard(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Notificaciones Push'),
                  subtitle: const Text('Alertas en tiempo real en tu celular'),
                  value: prefs.pushNotificationsEnabled,
                  onChanged: (v) => _update(ref, prefs.copyWith(pushNotificationsEnabled: v)),
                  activeTrackColor: FudiColors.primary.withValues(alpha: 0.5),
                  activeThumbColor: FudiColors.primary,
                ),
                const Divider(height: 1, indent: FudiSpacing.md),
                SwitchListTile(
                  title: const Text('Correo electrónico'),
                  subtitle: const Text('Resúmenes semanales y facturas'),
                  value: prefs.emailNotificationsEnabled,
                  onChanged: (v) => _update(ref, prefs.copyWith(emailNotificationsEnabled: v)),
                  activeTrackColor: FudiColors.primary.withValues(alpha: 0.5),
                  activeThumbColor: FudiColors.primary,
                ),
              ],
            ),
          ),
          const SizedBox(height: FudiSpacing.xl),
          Text('Alertas inteligentes', style: FudiTypography.labelMedium),
          const SizedBox(height: FudiSpacing.md),
          FudiSurfaceCard(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Favoritos'),
                  subtitle: const Text('Cuando tus locales favoritos publican ofertas'),
                  value: prefs.favoriteAlertsEnabled,
                  onChanged: (v) => _update(ref, prefs.copyWith(favoriteAlertsEnabled: v)),
                  activeTrackColor: FudiColors.primary.withValues(alpha: 0.5),
                  activeThumbColor: FudiColors.primary,
                ),
                const Divider(height: 1, indent: FudiSpacing.md),
                SwitchListTile(
                  title: const Text('Recordatorios de recogida'),
                  subtitle: const Text('Avisos antes de que cierre la ventana'),
                  value: prefs.pickupRemindersEnabled,
                  onChanged: (v) => _update(ref, prefs.copyWith(pickupRemindersEnabled: v)),
                  activeTrackColor: FudiColors.primary.withValues(alpha: 0.5),
                  activeThumbColor: FudiColors.primary,
                ),
                const Divider(height: 1, indent: FudiSpacing.md),
                SwitchListTile(
                  title: const Text('Ofertas de último minuto'),
                  subtitle: const Text('Paquetes a punto de expirar cerca de ti'),
                  value: prefs.lastMinuteDealsEnabled,
                  onChanged: (v) => _update(ref, prefs.copyWith(lastMinuteDealsEnabled: v)),
                  activeTrackColor: FudiColors.primary.withValues(alpha: 0.5),
                  activeThumbColor: FudiColors.primary,
                ),
              ],
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
}
