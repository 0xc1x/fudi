import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../core/routing/route_names.dart';
import '../../../core/ui/fudi_colors.dart';
import '../../../core/ui/fudi_pressable_scale.dart';
import '../../../core/ui/atoms/icons/fudi_icons.dart';
import '../../../core/ui/fudi_settings_group.dart';
import '../../../core/ui/fudi_settings_item.dart';
import '../../../core/ui/fudi_spacing.dart';
import '../../../core/ui/fudi_typography.dart';
import '../../../core/ui/atoms/fudi_stat_card.dart';
import '../../../core/ui/fudi_empty_state.dart';
import '../../../core/ui/fudi_error_state.dart';
import '../../auth/domain/user_profile.dart';
import '../../auth/presentation/auth_state_provider.dart';
import 'components/guest_welcome_view.dart';
import 'components/profile_order_card.dart';
import 'components/profile_sign_out_button.dart';
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
    final isAuthenticated = authState.isAuthenticated;
    final profile = authState.profile;

    if (!isAuthenticated) {
      return const GuestWelcomeView();
    }

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
                    child: FudiStatCard(
                      icon: FudiIcons.award,
                      value: '\$${_formatPrice(stats.totalSaved)}',
                      label: 'Ahorrado',
                    ),
                  ),
                  const SizedBox(width: FudiSpacing.sm),
                  Expanded(
                    child: FudiStatCard(
                      icon: FudiIcons.package_,
                      value: '${stats.totalOrders}',
                      label: 'Pedidos',
                    ),
                  ),
                  const SizedBox(width: FudiSpacing.sm),
                  Expanded(
                    child: FudiStatCard(
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
                  Expanded(
                    child: FudiStatCard(
                      icon: FudiIcons.award,
                      value: '\$0',
                      label: 'Ahorrado',
                    ),
                  ),
                  const SizedBox(width: FudiSpacing.sm),
                  Expanded(
                    child: FudiStatCard(
                      icon: FudiIcons.package_,
                      value: '0',
                      label: 'Pedidos',
                    ),
                  ),
                  const SizedBox(width: FudiSpacing.sm),
                  Expanded(
                    child: FudiStatCard(
                      icon: FudiIcons.leaf,
                      value: '0 kg',
                      label: 'CO\u2082 evitado',
                    ),
                  ),
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
        labelStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
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
          return const FudiEmptyState(
            title: 'Aún no tienes pedidos',
            description: 'Tus pedidos completados y activos aparecerán aquí',
            icon: FudiIcons.shoppingBag,
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
                ...upcoming.map(
                  (o) => Padding(
                    padding: const EdgeInsets.only(bottom: FudiSpacing.md),
                    child: ProfileOrderCard.fromUserOrder(o),
                  ),
                ),
              ],
              if (past.isNotEmpty) ...[
                Row(
                  children: [
                    Expanded(
                      child: Text('Pedidos anteriores', style: FudiTypography.h2),
                    ),
                    FudiPressableScale(
                      onTap: () => context.push('/orders'),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: FudiSpacing.sm,
                          vertical: FudiSpacing.xs,
                        ),
                        child: Text(
                          past.length > 5
                              ? 'Ver todo (${past.length})'
                              : 'Ver todo',
                          style: FudiTypography.bodySmall.copyWith(
                            color: FudiColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: FudiSpacing.md),
                ...past.take(5).map(
                  (o) => Padding(
                    padding: const EdgeInsets.only(bottom: FudiSpacing.md),
                    child: ProfileOrderCard.fromUserOrder(o),
                  ),
                ),
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
      error: (error, _) => const FudiErrorState(
        message: 'Error al cargar pedidos',
      ),
    );
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
          FudiSettingsGroup(
            title: 'Cuenta',
            items: [
              FudiSettingsItem(
                icon: FudiIcons.user,
                label: 'Editar perfil',
                onTap: () => context.push(RouteNames.profileEditPath),
              ),
              FudiSettingsItem(
                icon: FudiIcons.creditCard,
                label: 'Métodos de pago',
                onTap: () => context.push(RouteNames.paymentMethodsPath),
              ),
              FudiSettingsItem(
                icon: FudiIcons.mapPin,
                label: 'Direcciones guardadas',
                onTap: () => context.push(RouteNames.savedAddressesPath),
              ),
            ],
          ),
          const SizedBox(height: FudiSpacing.xl),
          FudiSettingsGroup(
            title: 'Preferencias',
            items: [
              FudiSettingsItem(
                icon: FudiIcons.bell,
                label: 'Notificaciones',
                onTap: () => context.push(RouteNames.profileNotificationsPath),
              ),
              FudiSettingsItem(
                icon: FudiIcons.heartOutline,
                label: 'Favoritos',
                onTap: () => context.push(RouteNames.favoritesPath),
              ),
              FudiSettingsItem(
                icon: FudiIcons.settings,
                label: 'Configuración',
                onTap: () => context.push(RouteNames.profileSettingsPath),
              ),
            ],
          ),
          const SizedBox(height: FudiSpacing.xl),
          FudiSettingsGroup(
            title: 'Ayuda',
            items: [
              FudiSettingsItem(
                icon: FudiIcons.helpCircle,
                label: 'Centro de ayuda',
                onTap: () => context.push(RouteNames.helpPath),
              ),
            ],
          ),
          const SizedBox(height: FudiSpacing.xl),
          ProfileSignOutButton(),
          const SizedBox(height: FudiSpacing.xxl),
        ],
      ),
    );
  }
}


