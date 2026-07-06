import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/ui/fudi_colors.dart';
import '../../../../core/ui/fudi_spacing.dart';
import '../../../../core/ui/fudi_theme.dart';
import '../../../../core/ui/fudi_typography.dart';
import '../../../../core/ui/fudi_surface_card.dart';
import '../../../../core/ui/atoms/icons/fudi_icons.dart';
import '../../../notifications/presentation/push_permission_helper.dart';
import '../../domain/business_notification_preferences.dart';
import '../business_providers.dart';

class BusinessNotificationsScreen extends ConsumerWidget {
  const BusinessNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final themeExt = theme.extension<FudiThemeExtension>();
    final businessAsync = ref.watch(currentBusinessProvider);
    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(FudiSpacing.sm),
          child: InkWell(
            onTap: () => context.pop(),
            borderRadius: BorderRadius.circular(FudiRadius.full),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: themeExt?.mutedBackground ?? FudiColors.muted,
                shape: BoxShape.circle,
              ),
              child: const Icon(FudiIcons.chevronLeft, size: 20),
            ),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Notificaciones', style: FudiTypography.h4),
            Text(
              'Gestiona tus alertas',
              style: FudiTypography.bodySmall.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        elevation: 0,
        backgroundColor: colorScheme.surface,
      ),
      body: businessAsync.when(
        data: (business) {
          if (business == null) {
            return const Center(child: Text('No hay negocio seleccionado'));
          }
          return _BusinessNotificationsBody(businessId: business.id);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _BusinessNotificationsBody extends ConsumerWidget {
  const _BusinessNotificationsBody({required this.businessId});

  final String businessId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefsAsync = ref.watch(
      businessNotificationPreferencesProvider(businessId),
    );

    return prefsAsync.when(
      data: (prefs) => _Content(businessId: businessId, prefs: prefs),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }
}

class _Content extends ConsumerWidget {
  const _Content({required this.businessId, required this.prefs});

  final String businessId;
  final BusinessNotificationPreferences prefs;

  void _toggle(
    WidgetRef ref,
    BusinessNotificationPreferences Function(BusinessNotificationPreferences)
    update,
  ) {
    final updated = update(prefs);
    unawaited(ref
        .read(businessNotificationRepositoryProvider)
        .updatePreferences(businessId, updated));
    ref.invalidate(businessNotificationPreferencesProvider(businessId));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(FudiSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoBanner(),
          const SizedBox(height: FudiSpacing.md),
          _buildEventTypes(ref),
          const SizedBox(height: FudiSpacing.md),
          _buildChannels(context, ref),
          const SizedBox(height: FudiSpacing.md),
          _buildQuietHours(context, ref),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildInfoBanner() {
    return Container(
      padding: const EdgeInsets.all(FudiSpacing.md),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(FudiRadius.xl),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            FudiColors.primary,
            FudiColors.primary.withValues(alpha: 0.8),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: FudiColors.primary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: FudiColors.primaryForeground.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(FudiIcons.bell, size: 24, color: FudiColors.primaryForeground),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mantente informado',
                  style: FudiTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: FudiColors.primaryForeground,
                  ),
                ),
                Text(
                  'No te pierdas ningún pedido importante',
                  style: FudiTypography.bodySmall.copyWith(
                    color: FudiColors.primaryForeground.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventTypes(WidgetRef ref) {
    return FudiSurfaceCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(FudiSpacing.md),
            child: Text('Tipos de notificaciones', style: FudiTypography.h4),
          ),
          const Divider(height: 1, color: FudiColors.border),
          _EventTypeTile(
            icon: FudiIcons.shoppingBag,
            title: 'Nuevos pedidos',
            description: 'Notificación cuando recibes un nuevo pedido',
            value: prefs.newOrdersEnabled,
            onChanged: (v) =>
                _toggle(ref, (p) => p.copyWith(newOrdersEnabled: v)),
          ),
          _EventTypeTile(
            icon: FudiIcons.bell,
            title: 'Hora de recogida',
            description: 'Recordatorio 30 minutos antes de la hora de recogida',
            value: prefs.pickupReadyEnabled,
            onChanged: (v) =>
                _toggle(ref, (p) => p.copyWith(pickupReadyEnabled: v)),
          ),
          _EventTypeTile(
            icon: FudiIcons.messageSquare,
            title: 'Nuevas reseñas',
            description: 'Cuando un cliente deja una reseña',
            value: prefs.reviewsEnabled,
            onChanged: (v) =>
                _toggle(ref, (p) => p.copyWith(reviewsEnabled: v)),
          ),
          _EventTypeTile(
            icon: FudiIcons.alertCircle,
            title: 'Stock bajo',
            description: 'Alerta cuando un producto tiene pocas unidades',
            value: prefs.lowStockEnabled,
            onChanged: (v) =>
                _toggle(ref, (p) => p.copyWith(lowStockEnabled: v)),
          ),
          _EventTypeTile(
            icon: FudiIcons.trendingUp,
            title: 'Resumen diario',
            description: 'Estadísticas del día al final de la jornada',
            value: prefs.dailySummaryEnabled,
            onChanged: (v) =>
                _toggle(ref, (p) => p.copyWith(dailySummaryEnabled: v)),
          ),
        ],
      ),
    );
  }

  Widget _buildChannels(BuildContext context, WidgetRef ref) {
    return FudiSurfaceCard(
      padding: const EdgeInsets.all(FudiSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Canales de notificación', style: FudiTypography.h4),
          const SizedBox(height: FudiSpacing.sm),
          _ChannelTile(
            title: 'Notificaciones push',
            subtitle: isPushSupported
                ? 'En la aplicación'
                : 'No disponible en este navegador',
            value: prefs.pushEnabled,
            onChanged: isPushSupported
                ? (v) async {
                    if (v) {
                      final granted =
                          await ensurePushPermission(context, ref);
                      if (!context.mounted || !granted) return;
                    }
                    _toggle(ref, (p) => p.copyWith(pushEnabled: v));
                  }
                : null,
          ),
          _ChannelTile(
            title: 'Email',
            subtitle: 'Correo electrónico',
            value: prefs.emailEnabled,
            onChanged: (v) => _toggle(ref, (p) => p.copyWith(emailEnabled: v)),
          ),
          _ChannelTile(
            title: 'SMS',
            subtitle: 'Próximamente',
            value: prefs.smsEnabled,
            onChanged: null,
          ),
          _ChannelTile(
            title: 'WhatsApp',
            subtitle: 'Próximamente',
            value: prefs.whatsappEnabled,
            onChanged: null,
          ),
        ],
      ),
    );
  }

  Widget _buildQuietHours(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final from = prefs.quietHoursFrom;
    final to = prefs.quietHoursTo;

    return FudiSurfaceCard(
      padding: const EdgeInsets.all(FudiSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Horario de silencio', style: FudiTypography.h4),
          const SizedBox(height: 4),
          Text(
            'No recibirás notificaciones durante estas horas',
            style: FudiTypography.bodySmall.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: FudiSpacing.md),
          Row(
            children: [
              Expanded(
                child: _TimeField(
                  label: 'Desde',
                  value: from,
                  onPicked: (t) {
                    final updated = prefs.copyWith(quietHoursFrom: t);
                    unawaited(ref
                        .read(businessNotificationRepositoryProvider)
                        .updatePreferences(businessId, updated));
                    ref.invalidate(
                      businessNotificationPreferencesProvider(businessId),
                    );
                  },
                  onClear: from == null
                      ? null
                      : () {
                          final updated = prefs.copyWith(quietHoursFrom: null);
                          unawaited(ref
                              .read(businessNotificationRepositoryProvider)
                              .updatePreferences(businessId, updated));
                          ref.invalidate(
                            businessNotificationPreferencesProvider(businessId),
                          );
                        },
                ),
              ),
              const SizedBox(width: FudiSpacing.md),
              Expanded(
                child: _TimeField(
                  label: 'Hasta',
                  value: to,
                  onPicked: (t) {
                    final updated = prefs.copyWith(quietHoursTo: t);
                    unawaited(ref
                        .read(businessNotificationRepositoryProvider)
                        .updatePreferences(businessId, updated));
                    ref.invalidate(
                      businessNotificationPreferencesProvider(businessId),
                    );
                  },
                  onClear: to == null
                      ? null
                      : () {
                          final updated = prefs.copyWith(quietHoursTo: null);
                          unawaited(ref
                              .read(businessNotificationRepositoryProvider)
                              .updatePreferences(businessId, updated));
                          ref.invalidate(
                            businessNotificationPreferencesProvider(businessId),
                          );
                        },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EventTypeTile extends StatelessWidget {
  const _EventTypeTile({
    required this.icon,
    required this.title,
    required this.description,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String description;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final mutedBg = Theme.of(context).extension<FudiThemeExtension>()?.mutedBackground ?? FudiColors.muted;

    return Padding(
      padding: const EdgeInsets.all(FudiSpacing.md),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: value
                  ? FudiColors.primary.withValues(alpha: 0.1)
                  : mutedBg,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 20,
              color: value ? FudiColors.primary : colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: FudiTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  description,
                  style: FudiTypography.bodySmall.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: FudiColors.primary,
          ),
        ],
      ),
    );
  }
}

class _ChannelTile extends StatelessWidget {
  const _ChannelTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: FudiSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: FudiTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  subtitle,
                  style: FudiTypography.bodySmall.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: FudiColors.primary,
          ),
        ],
      ),
    );
  }
}

class _TimeField extends StatelessWidget {
  const _TimeField({
    required this.label,
    required this.value,
    required this.onPicked,
    this.onClear,
  });

  final String label;
  final String? value;
  final ValueChanged<String> onPicked;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: FudiTypography.bodySmall.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        InkWell(
          onTap: () async {
            final initial = value != null
                ? TimeOfDay(
                    hour: int.parse(value!.split(':')[0]),
                    minute: int.parse(value!.split(':')[1]),
                  )
                : const TimeOfDay(hour: 22, minute: 0);

            final picked = await showTimePicker(
              context: context,
              initialTime: initial,
              builder: (ctx, child) => Theme(
                data: Theme.of(ctx).copyWith(
                  colorScheme: const ColorScheme.light(
                    primary: FudiColors.primary,
                  ),
                ),
                child: child!,
              ),
            );
            if (picked != null) {
              onPicked(
                '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}',
              );
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              border: Border.all(color: FudiColors.border),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value != null ? value! : '--:--',
                  style: FudiTypography.bodyMedium.copyWith(
                    color: value != null
                        ? colorScheme.onSurface
                        : colorScheme.onSurfaceVariant,
                  ),
                ),
                if (onClear != null) ...[
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: onClear,
                    child: Icon(
                      Icons.close,
                      size: 16,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}
