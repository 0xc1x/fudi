import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/ui/fudi_colors.dart';
import '../../../core/ui/fudi_spacing.dart';
import '../../../core/ui/fudi_typography.dart';
import '../../../core/ui/fudi_sticky_page_header.dart';
import '../../../core/ui/fudi_surface_card.dart';
import '../../notifications/presentation/push_permission_helper.dart';
import '../domain/consumer_notification_preferences.dart';
import 'profile_providers.dart';

class NotificationSettingsScreen extends ConsumerWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefsAsync = ref.watch(consumerNotificationPreferencesProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const FudiStickyPageHeader(title: 'Notificaciones'),
      body: prefsAsync.when(
        data: (prefs) => _buildContent(context, ref, prefs),
        loading: () => const Center(
          child: CircularProgressIndicator(
            strokeWidth: 3,
            color: FudiColors.primary,
          ),
        ),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(FudiSpacing.xl),
            child: Text(
              'No pudimos cargar tus preferencias: $error',
              style: FudiTypography.bodyMedium.copyWith(
                color: FudiColors.destructiveVibrant,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    ConsumerNotificationPreferences prefs,
  ) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(FudiSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner Informativo UX (Aumenta la retención de usuarios con alertas activas)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(FudiSpacing.lg),
            decoration: BoxDecoration(
              color: FudiColors.primary.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: FudiColors.primary.withValues(alpha: 0.15),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.notifications_active_outlined,
                  color: FudiColors.primary,
                  size: 24,
                ),
                const SizedBox(width: FudiSpacing.md),
                Expanded(
                  child: Text(
                    'Configura tus alertas para no perderte ningún paquete sorpresa y rescatar comida a tiempo.',
                    style: FudiTypography.bodySmall.copyWith(
                      color: FudiColors.primary,
                      fontWeight: FontWeight.w500,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: FudiSpacing.xl),

          // SECCIÓN 1: Canales de comunicación
          Text(
            'Canales de comunicación',
            style: FudiTypography.labelSmall.copyWith(
              fontWeight: FontWeight.bold,
              color: FudiColors.mutedForeground,
            ),
          ),
          const SizedBox(height: FudiSpacing.sm),
          FudiSurfaceCard(
            child: Column(
              children: [
                _buildCustomSwitchTile(
                  title: 'Notificaciones Push',
                  subtitle: isPushSupported
                      ? 'Alertas en tiempo real en tu celular'
                      : 'No disponible en este navegador',
                  icon: Icons.phone_android_rounded,
                  value: prefs.pushEnabled,
                  onChanged: isPushSupported
                      ? (v) async {
                          if (v) {
                            final granted =
                                await ensurePushPermission(context, ref);
                            if (!context.mounted || !granted) return;
                          }
                          _update(ref, prefs.copyWith(pushEnabled: v));
                        }
                      : null,
                ),
                const Divider(height: 1, color: FudiColors.borderSolid),
                _buildCustomSwitchTile(
                  title: 'Correo electrónico',
                  subtitle: 'Resúmenes semanales y facturas',
                  icon: Icons.mail_outline_rounded,
                  value: prefs.emailEnabled,
                  onChanged: (v) =>
                      _update(ref, prefs.copyWith(emailEnabled: v)),
                ),
                const Divider(height: 1, color: FudiColors.borderSolid),
                _buildCustomSwitchTile(
                  title: 'SMS',
                  subtitle: 'Alertas de texto de respaldo',
                  icon: Icons.sms_outlined,
                  value: prefs.smsEnabled,
                  isUpcoming: true,
                  onChanged: null,
                ),
                const Divider(height: 1, color: FudiColors.borderSolid),
                _buildCustomSwitchTile(
                  title: 'WhatsApp',
                  subtitle: 'Recibe confirmaciones directo en tu chat',
                  icon: Icons.chat_bubble_outline_rounded,
                  value: prefs.whatsappEnabled,
                  isUpcoming: true,
                  onChanged: null,
                ),
              ],
            ),
          ),

          const SizedBox(height: FudiSpacing.xl),

          // SECCIÓN 2: Alertas Inteligentes
          Text(
            'Alertas inteligentes',
            style: FudiTypography.labelSmall.copyWith(
              fontWeight: FontWeight.bold,
              color: FudiColors.mutedForeground,
            ),
          ),
          const SizedBox(height: FudiSpacing.sm),
          FudiSurfaceCard(
            child: Column(
              children: [
                _buildCustomSwitchTile(
                  title: 'Favoritos',
                  subtitle: 'Cuando tus locales favoritos publican ofertas',
                  icon: Icons.star_border_rounded,
                  value: prefs.favoriteAlertsEnabled,
                  onChanged: (v) =>
                      _update(ref, prefs.copyWith(favoriteAlertsEnabled: v)),
                ),
                const Divider(height: 1, color: FudiColors.borderSolid),
                _buildCustomSwitchTile(
                  title: 'Recordatorios de recogida',
                  subtitle: 'Avisos antes de que cierre la ventana del local',
                  icon: Icons.access_time_rounded,
                  value: prefs.pickupRemindersEnabled,
                  onChanged: (v) =>
                      _update(ref, prefs.copyWith(pickupRemindersEnabled: v)),
                ),
                const Divider(height: 1, color: FudiColors.borderSolid),
                _buildCustomSwitchTile(
                  title: 'Ofertas de último minuto',
                  subtitle: 'Paquetes a punto de expirar muy cerca de ti',
                  icon: Icons.flash_on_rounded,
                  value: prefs.lastMinuteDealsEnabled,
                  onChanged: (v) =>
                      _update(ref, prefs.copyWith(lastMinuteDealsEnabled: v)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Componente de celda optimizada para mantener la coherencia UI
  Widget _buildCustomSwitchTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool>? onChanged,
    bool isUpcoming = false,
  }) {
    final bool isDisabled = onChanged == null;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: SwitchListTile.adaptive(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: FudiSpacing.md,
          vertical: 2,
        ),
        activeTrackColor: FudiColors.primary.withValues(alpha: 0.2),
        activeThumbColor: FudiColors.primary,
        inactiveTrackColor: FudiColors.inputBackground,
        value: value,
        onChanged: onChanged,
        title: Row(
          children: [
            Flexible(
              child: Text(
                title,
                style: FudiTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDisabled
                      ? FudiColors.foreground.withValues(alpha: 0.4)
                      : FudiColors.foreground,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isUpcoming) ...[
              const SizedBox(width: FudiSpacing.sm),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: FudiColors.inputBackground,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Próximamente',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: FudiColors.mutedForeground.withValues(alpha: 0.8),
                  ),
                ),
              ),
            ],
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Text(
            subtitle,
            style: FudiTypography.bodySmall.copyWith(
              color: isDisabled
                  ? FudiColors.mutedForeground.withValues(alpha: 0.4)
                  : FudiColors.mutedForeground,
              height: 1.2,
            ),
          ),
        ),
        secondary: CircleAvatar(
          radius: 18,
          backgroundColor: isDisabled
              ? FudiColors.inputBackground.withValues(alpha: 0.5)
              : FudiColors.inputBackground,
          child: Icon(
            icon,
            size: 20,
            color: isDisabled
                ? FudiColors.foreground.withValues(alpha: 0.3)
                : FudiColors.foreground,
          ),
        ),
      ),
    );
  }

  void _update(WidgetRef ref, ConsumerNotificationPreferences prefs) {
    unawaited(ref.read(consumerNotificationRepositoryProvider).updatePreferences(prefs));
    ref.invalidate(consumerNotificationPreferencesProvider);
  }
}
