import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/ui/fudi_colors.dart';
import '../../../../core/ui/fudi_spacing.dart';
import '../../../../core/ui/fudi_typography.dart';
import '../../../../core/ui/fudi_surface_card.dart';
import '../../../../core/ui/atoms/icons/fudi_icons.dart';

class BusinessNotificationsScreen extends StatefulWidget {
  const BusinessNotificationsScreen({super.key});

  @override
  State<BusinessNotificationsScreen> createState() =>
      _BusinessNotificationsScreenState();
}

class _BusinessNotificationsScreenState
    extends State<BusinessNotificationsScreen> {
  final _settings = <_NotificationSetting>[
    _NotificationSetting(
      id: 'new-orders',
      title: 'Nuevos pedidos',
      description: 'Notificación cuando recibes un nuevo pedido',
      icon: FudiIcons.shoppingBag,
      enabled: true,
    ),
    _NotificationSetting(
      id: 'pickup-ready',
      title: 'Hora de recogida',
      description: 'Recordatorio 30 minutos antes de la hora de recogida',
      icon: FudiIcons.bell,
      enabled: true,
    ),
    _NotificationSetting(
      id: 'reviews',
      title: 'Nuevas reseñas',
      description: 'Cuando un cliente deja una reseña',
      icon: FudiIcons.messageSquare,
      enabled: true,
    ),
    _NotificationSetting(
      id: 'low-stock',
      title: 'Stock bajo',
      description: 'Alerta cuando un producto tiene pocas unidades',
      icon: FudiIcons.alertCircle,
      enabled: false,
    ),
    _NotificationSetting(
      id: 'daily-summary',
      title: 'Resumen diario',
      description: 'Estadísticas del día al final de la jornada',
      icon: FudiIcons.trendingUp,
      enabled: true,
    ),
  ];

  final _channels = <_NotificationChannel>[
    _NotificationChannel(
      title: 'Notificaciones push',
      subtitle: 'En la aplicación',
      enabled: true,
    ),
    _NotificationChannel(
      title: 'Email',
      subtitle: 'centro@panaderiaartesanal.ec',
      enabled: true,
    ),
    _NotificationChannel(
      title: 'SMS',
      subtitle: '+593 2 234 5678',
      enabled: false,
    ),
  ];

  TimeOfDay _quietFrom = const TimeOfDay(hour: 22, minute: 0);
  TimeOfDay _quietTo = const TimeOfDay(hour: 8, minute: 0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FudiColors.background,
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(FudiSpacing.sm),
          child: InkWell(
            onTap: () => context.pop(),
            borderRadius: BorderRadius.circular(FudiRadius.full),
            child: Container(
              decoration: BoxDecoration(
                color: FudiColors.muted,
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
                color: FudiColors.mutedForeground,
              ),
            ),
          ],
        ),
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(FudiSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoBanner(),
            const SizedBox(height: FudiSpacing.md),
            _buildNotificationTypes(),
            const SizedBox(height: FudiSpacing.md),
            _buildChannels(),
            const SizedBox(height: FudiSpacing.md),
            _buildQuietHours(),
            const SizedBox(height: FudiSpacing.lg),
            _buildSaveButton(),
            const SizedBox(height: 80),
          ],
        ),
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
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(FudiIcons.bell, size: 24, color: Colors.white),
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
                    color: Colors.white,
                  ),
                ),
                Text(
                  'No te pierdas ningún pedido importante',
                  style: FudiTypography.bodySmall.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationTypes() {
    return FudiSurfaceCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(FudiSpacing.md),
            child: const Text(
              'Tipos de notificaciones',
              style: FudiTypography.h4,
            ),
          ),
          const Divider(height: 1),
          ..._settings.map((setting) => _buildSettingTile(setting)),
        ],
      ),
    );
  }

  Widget _buildSettingTile(_NotificationSetting setting) {
    return Padding(
      padding: const EdgeInsets.all(FudiSpacing.md),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: setting.enabled
                  ? FudiColors.primary.withValues(alpha: 0.1)
                  : FudiColors.muted,
              shape: BoxShape.circle,
            ),
            child: Icon(
              setting.icon,
              size: 20,
              color: setting.enabled
                  ? FudiColors.primary
                  : FudiColors.mutedForeground,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  setting.title,
                  style: FudiTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  setting.description,
                  style: FudiTypography.bodySmall.copyWith(
                    color: FudiColors.mutedForeground,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: setting.enabled,
            onChanged: (val) {
              setState(() {
                final idx = _settings.indexWhere((s) => s.id == setting.id);
                if (idx != -1) {
                  _settings[idx] = _NotificationSetting(
                    id: setting.id,
                    title: setting.title,
                    description: setting.description,
                    icon: setting.icon,
                    enabled: val,
                  );
                }
              });
            },
            activeThumbColor: FudiColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildChannels() {
    return FudiSurfaceCard(
      padding: const EdgeInsets.all(FudiSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Canales de notificación', style: FudiTypography.h4),
          const SizedBox(height: FudiSpacing.sm),
          ..._channels.map((channel) => _buildChannelTile(channel)),
        ],
      ),
    );
  }

  Widget _buildChannelTile(_NotificationChannel channel) {
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
                  channel.title,
                  style: FudiTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  channel.subtitle,
                  style: FudiTypography.bodySmall.copyWith(
                    color: FudiColors.mutedForeground,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: channel.enabled,
            onChanged: (val) {
              setState(() {
                final idx = _channels.indexOf(channel);
                if (idx != -1) {
                  _channels[idx] = _NotificationChannel(
                    title: channel.title,
                    subtitle: channel.subtitle,
                    enabled: val,
                  );
                }
              });
            },
            activeThumbColor: FudiColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildQuietHours() {
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
              color: FudiColors.mutedForeground,
            ),
          ),
          const SizedBox(height: FudiSpacing.md),
          Row(
            children: [
              Expanded(
                child: _buildTimeField(
                  label: 'Desde',
                  time: _quietFrom,
                  onPick: (t) => setState(() => _quietFrom = t),
                ),
              ),
              const SizedBox(width: FudiSpacing.md),
              Expanded(
                child: _buildTimeField(
                  label: 'Hasta',
                  time: _quietTo,
                  onPick: (t) => setState(() => _quietTo = t),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeField({
    required String label,
    required TimeOfDay time,
    required ValueChanged<TimeOfDay> onPick,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: FudiTypography.bodySmall.copyWith(
            color: FudiColors.mutedForeground,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        InkWell(
          onTap: () async {
            final picked = await showTimePicker(
              context: context,
              initialTime: time,
              builder: (ctx, child) => Theme(
                data: Theme.of(ctx).copyWith(
                  colorScheme: const ColorScheme.light(
                    primary: FudiColors.primary,
                  ),
                ),
                child: child!,
              ),
            );
            if (picked != null) onPick(picked);
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
                Text(time.format(context), style: FudiTypography.bodyMedium),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Preferencias guardadas'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: FudiColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
        ),
        child: const Text(
          'Guardar cambios',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
  }
}

class _NotificationSetting {
  const _NotificationSetting({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.enabled,
  });

  final String id;
  final String title;
  final String description;
  final IconData icon;
  final bool enabled;
}

class _NotificationChannel {
  const _NotificationChannel({
    required this.title,
    required this.subtitle,
    required this.enabled,
  });

  final String title;
  final String subtitle;
  final bool enabled;
}
