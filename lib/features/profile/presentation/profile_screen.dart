import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../core/routing/route_names.dart';
import '../../../core/ui/fudi_colors.dart';
import '../../../core/ui/fudi_icons.dart';
import '../../../core/ui/fudi_spacing.dart';
import '../../../core/ui/fudi_typography.dart';
import '../../auth/domain/user_profile.dart';
import '../../auth/presentation/auth_state_provider.dart';
import '../domain/user_order.dart';
import 'profile_providers.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authSessionNotifierProvider);
    final profile = authState.profile;

    return Scaffold(
      backgroundColor: FudiColors.muted,
      body: Column(
        children: [
          _ProfileHeader(profile: profile),
          _ProfileTabs(tabController: _tabController),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                const _OrdersTab(),
                _SettingsTab(profile: profile),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileHeader extends ConsumerWidget {
  const _ProfileHeader({required this.profile});

  final UserProfile? profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(userStatsProvider);

    return Container(
      color: FudiColors.ring,
      padding: const EdgeInsets.fromLTRB(
        FudiSpacing.lg,
        FudiSpacing.lg + 8,
        FudiSpacing.lg,
        FudiSpacing.xl,
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: FudiColors.primary,
                  backgroundImage: profile?.avatarUrl != null
                      ? CachedNetworkImageProvider(profile!.avatarUrl!)
                      : null,
                  child: profile?.avatarUrl == null
                      ? Text(
                          _initials,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: FudiColors.ring,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: FudiSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profile?.fullName ?? 'Usuario Fudi',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: FudiColors.primary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        profile?.email ?? '',
                        style: TextStyle(
                          fontSize: 14,
                          color: FudiColors.primary.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: FudiSpacing.md),
            statsAsync.when(
              data: (stats) => Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      icon: FudiIcons.award,
                      value: '\$${_formatPrice(stats.totalSaved)}',
                      label: 'Ahorrado',
                    ),
                  ),
                  const SizedBox(width: FudiSpacing.sm),
                  Expanded(
                    child: _StatCard(
                      icon: FudiIcons.package_,
                      value: '${stats.totalOrders}',
                      label: 'Pedidos',
                    ),
                  ),
                  const SizedBox(width: FudiSpacing.sm),
                  Expanded(
                    child: _StatCard(
                      icon: FudiIcons.leaf,
                      value: '${stats.co2SavedKg.toStringAsFixed(1)} kg',
                      label: 'CO\u2082 evitado',
                    ),
                  ),
                ],
              ),
              loading: () => Row(
                children: List.generate(
                  3,
                  (_) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: FudiSpacing.xs,
                      ),
                      child: Container(
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(FudiRadius.xl),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              error: (_, _) => Row(
                children: [
                  Expanded(child: _StatCard(icon: FudiIcons.award, value: '\$0', label: 'Ahorrado')),
                  const SizedBox(width: FudiSpacing.sm),
                  Expanded(child: _StatCard(icon: FudiIcons.package_, value: '0', label: 'Pedidos')),
                  const SizedBox(width: FudiSpacing.sm),
                  Expanded(child: _StatCard(icon: FudiIcons.leaf, value: '0 kg', label: 'CO\u2082 evitado')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String get _initials {
    if (profile?.fullName == null || profile!.fullName!.isEmpty) return 'F';
    final parts = profile!.fullName!.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }

  String _formatPrice(double value) {
    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}k';
    }
    return value.toStringAsFixed(0);
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(FudiSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(FudiRadius.xl),
      ),
      child: Column(
        children: [
          Icon(icon, size: 20, color: FudiColors.primary.withValues(alpha: 0.6)),
          const SizedBox(height: FudiSpacing.xs),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: FudiColors.primary,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: FudiColors.primary.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileTabs extends StatelessWidget {
  const _ProfileTabs({required this.tabController});

  final TabController tabController;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: FudiColors.background,
      child: TabBar(
        controller: tabController,
        labelColor: FudiColors.primary,
        unselectedLabelColor: FudiColors.mutedForeground,
        labelStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        indicatorColor: FudiColors.primary,
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorWeight: 2,
        dividerColor: FudiColors.borderSolid,
        tabs: const [
          Tab(text: 'Historial'),
          Tab(text: 'Configuración'),
        ],
      ),
    );
  }
}

class _OrdersTab extends ConsumerWidget {
  const _OrdersTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(userOrdersProvider);

    return ordersAsync.when(
      data: (orders) {
        final upcoming = orders.where((o) => o.status.isUpcoming).toList();
        final past = orders.where((o) => o.status.isPast).toList();

        if (orders.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(FudiSpacing.xl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(FudiIcons.shoppingBag, size: 48, color: FudiColors.mutedForeground),
                  SizedBox(height: FudiSpacing.md),
                  Text('Aún no tienes pedidos', style: FudiTypography.bodyMedium),
                ],
              ),
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(FudiSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (upcoming.isNotEmpty) ...[
                Text('Próximos pedidos', style: FudiTypography.h2),
                const SizedBox(height: FudiSpacing.md),
                ...upcoming.map((o) => Padding(
                  padding: const EdgeInsets.only(bottom: FudiSpacing.md),
                  child: _OrderCard(order: o),
                )),
              ],
              if (past.isNotEmpty) ...[
                Text('Pedidos anteriores', style: FudiTypography.h2),
                const SizedBox(height: FudiSpacing.md),
                ...past.map((o) => Padding(
                  padding: const EdgeInsets.only(bottom: FudiSpacing.md),
                  child: _OrderCard(order: o),
                )),
              ],
            ],
          ),
        );
      },
      loading: () => SingleChildScrollView(
        padding: const EdgeInsets.all(FudiSpacing.lg),
        child: Column(
          children: List.generate(
            3,
            (_) => Padding(
              padding: const EdgeInsets.only(bottom: FudiSpacing.md),
              child: Container(
                height: 120,
                decoration: BoxDecoration(
                  color: FudiColors.muted,
                  borderRadius: BorderRadius.circular(FudiRadius.xl),
                ),
              ),
            ),
          ),
        ),
      ),
      error: (error, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(FudiSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(FudiIcons.error, size: 48, color: FudiColors.destructive),
              const SizedBox(height: FudiSpacing.sm),
              Text('Error al cargar pedidos', style: FudiTypography.bodyMedium),
            ],
          ),
        ),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order});

  final UserOrder order;

  @override
  Widget build(BuildContext context) {
    final (statusColor, statusTextColor, statusLabel) = switch (order.status) {
      OrderStatus.pending => (FudiColors.ring, FudiColors.primary, 'Pendiente'),
      OrderStatus.confirmed => (FudiColors.ring, FudiColors.primary, 'Confirmado'),
      OrderStatus.readyForPickup => (FudiColors.primary, FudiColors.primaryForeground, 'Listo para recoger'),
      OrderStatus.pickedUp => (FudiColors.muted, FudiColors.mutedForeground, 'Recogido'),
      OrderStatus.completed => (FudiColors.muted, FudiColors.mutedForeground, 'Completado'),
      OrderStatus.cancelled => (FudiColors.destructive.withValues(alpha: 0.1), FudiColors.destructive, 'Cancelado'),
      OrderStatus.expired => (FudiColors.muted, FudiColors.mutedForeground, 'Expirado'),
    };

    return GestureDetector(
      onTap: () => context.push('/orders/${order.id}'),
      child: Container(
        padding: const EdgeInsets.all(FudiSpacing.md),
        decoration: BoxDecoration(
          color: FudiColors.background,
          borderRadius: BorderRadius.circular(FudiRadius.xl),
          border: Border.all(color: FudiColors.borderSolid),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(order.businessName, style: FudiTypography.labelSmall),
                      const SizedBox(height: 4),
                      Text(
                        _formatDate(order.createdAt),
                        style: FudiTypography.bodySmall,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: FudiSpacing.md,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(FudiRadius.full),
                  ),
                  child: Text(
                    statusLabel,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: statusTextColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: FudiSpacing.md),
            Divider(height: 1, color: FudiColors.borderSolid),
            const SizedBox(height: FudiSpacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  order.pickupTime != null
                      ? 'Recogida: ${_formatPickupTime(order.pickupTime!)}'
                      : 'Recogida: por confirmar',
                  style: FudiTypography.bodySmall,
                ),
                Text(
                  '\$${order.price.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: FudiColors.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      '', 'ene', 'feb', 'mar', 'abr', 'may', 'jun',
      'jul', 'ago', 'sep', 'oct', 'nov', 'dic'
    ];
    return '${date.day} ${months[date.month]} ${date.year}';
  }

  String _formatPickupTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

class _SettingsTab extends ConsumerWidget {
  const _SettingsTab({required this.profile});

  final UserProfile? profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(FudiSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SettingsGroup(
            title: 'Cuenta',
            items: [
              _SettingsItem(
                icon: FudiIcons.user,
                label: 'Editar perfil',
                onTap: () => context.push(RouteNames.profileEditPath),
              ),
              _SettingsItem(
                icon: FudiIcons.creditCard,
                label: 'Métodos de pago',
                onTap: () => context.push(RouteNames.paymentMethodsPath),
              ),
              _SettingsItem(
                icon: FudiIcons.mapPin,
                label: 'Direcciones guardadas',
                onTap: () => context.push(RouteNames.savedAddressesPath),
              ),
            ],
          ),
          const SizedBox(height: FudiSpacing.xl),
          _SettingsGroup(
            title: 'Preferencias',
            items: [
              _SettingsItem(
                icon: FudiIcons.bell,
                label: 'Notificaciones',
                onTap: () => context.push(RouteNames.profileNotificationsPath),
              ),
              _SettingsItem(
                icon: FudiIcons.heartOutline,
                label: 'Favoritos',
                onTap: () => context.push(RouteNames.favoritesPath),
              ),
              _SettingsItem(
                icon: FudiIcons.settings,
                label: 'Configuración',
                onTap: () => context.push(RouteNames.profileSettingsPath),
              ),
            ],
          ),
          const SizedBox(height: FudiSpacing.xl),
          _SettingsGroup(
            title: 'Ayuda',
            items: [
              _SettingsItem(
                icon: FudiIcons.helpCircle,
                label: 'Centro de ayuda',
                onTap: () => context.push(RouteNames.helpPath),
              ),
            ],
          ),
          const SizedBox(height: FudiSpacing.xl),
          _SignOutButton(),
          const SizedBox(height: FudiSpacing.xxl),
        ],
      ),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.title, required this.items});

  final String title;
  final List<_SettingsItem> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: FudiTypography.h2),
        const SizedBox(height: FudiSpacing.md),
        Container(
          decoration: BoxDecoration(
            color: FudiColors.background,
            borderRadius: BorderRadius.circular(FudiRadius.xl),
            border: Border.all(color: FudiColors.borderSolid),
          ),
          child: Column(
            children: items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return Column(
                children: [
                  item,
                  if (index < items.length - 1)
                    Divider(
                      height: 1,
                      thickness: 1,
                      color: FudiColors.borderSolid,
                      indent: FudiSpacing.lg + 20 + FudiSpacing.md,
                    ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _SettingsItem extends StatelessWidget {
  const _SettingsItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(FudiRadius.xl),
      child: Padding(
        padding: const EdgeInsets.all(FudiSpacing.md),
        child: Row(
          children: [
            Icon(icon, size: 20, color: FudiColors.mutedForeground),
            const SizedBox(width: FudiSpacing.md),
            Expanded(
              child: Text(label, style: FudiTypography.labelSmall),
            ),
            Icon(
              FudiIcons.chevronRight,
              size: 20,
              color: FudiColors.mutedForeground,
            ),
          ],
        ),
      ),
    );
  }
}

class _SignOutButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authController = ref.read(authControllerProvider.notifier);

    return GestureDetector(
      onTap: () => _showSignOutDialog(context, authController),
      child: Container(
        padding: const EdgeInsets.all(FudiSpacing.md),
        decoration: BoxDecoration(
          color: FudiColors.background,
          borderRadius: BorderRadius.circular(FudiRadius.xl),
          border: Border.all(color: FudiColors.borderSolid),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(FudiIcons.logOut, size: 20, color: FudiColors.destructive),
            const SizedBox(width: FudiSpacing.sm),
            Text(
              'Cerrar sesión',
              style: FudiTypography.labelSmall.copyWith(
                color: FudiColors.destructive,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSignOutDialog(BuildContext context, AuthController authController) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Estás seguro de que deseas cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              authController.signOut();
            },
            style: FilledButton.styleFrom(
              backgroundColor: FudiColors.destructive,
            ),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
  }
}
