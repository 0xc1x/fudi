import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../core/routing/route_names.dart';
import '../../../core/ui/fudi_colors.dart';
import '../../../core/ui/fudi_spacing.dart';
import '../../../core/ui/fudi_typography.dart';
import '../../auth/domain/user_profile.dart';
import '../../auth/presentation/auth_state_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authSessionNotifierProvider);
    final profile = authState.profile;

    return Scaffold(
      appBar: AppBar(
        title: Text('Mi Perfil', style: FudiTypography.headlineMedium),
        backgroundColor: FudiColors.background,
        surfaceTintColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(FudiSpacing.lg),
        child: Column(
          children: [
            _ProfileHeader(profile: profile),
            const SizedBox(height: FudiSpacing.xl),
            _ProfileMenuSection(
              items: [
                _MenuItem(
                  icon: Icons.person_outline,
                  label: 'Editar perfil',
                  onTap: () => context.go(RouteNames.profileEditPath),
                ),
                _MenuItem(
                  icon: Icons.shopping_bag_outlined,
                  label: 'Mis pedidos',
                  onTap: () => context.go(RouteNames.ordersPath),
                ),
                _MenuItem(
                  icon: Icons.favorite_outline,
                  label: 'Favoritos',
                  onTap: () => context.go(RouteNames.favoritesPath),
                ),
              ],
            ),
            const SizedBox(height: FudiSpacing.lg),
            _ProfileMenuSection(
              items: [
                _MenuItem(
                  icon: Icons.notifications_outlined,
                  label: 'Notificaciones',
                  onTap: () {},
                ),
                _MenuItem(
                  icon: Icons.settings_outlined,
                  label: 'Configuración',
                  onTap: () {},
                ),
                _MenuItem(
                  icon: Icons.help_outline,
                  label: 'Ayuda y soporte',
                  onTap: () {},
                ),
                _MenuItem(
                  icon: Icons.info_outline,
                  label: 'Sobre Fudi',
                  onTap: () => context.go(RouteNames.aboutPath),
                ),
              ],
            ),
            const SizedBox(height: FudiSpacing.xl),
            _SignOutButton(),
            const SizedBox(height: FudiSpacing.xxl),
          ],
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.profile});

  final UserProfile? profile;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 48,
          backgroundColor: FudiColors.secondary,
          backgroundImage: profile?.avatarUrl != null
              ? CachedNetworkImageProvider(profile!.avatarUrl!)
              : null,
          child: profile?.avatarUrl == null
              ? Text(
                  _initials,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: FudiColors.primary,
                  ),
                )
              : null,
        ),
        const SizedBox(height: FudiSpacing.md),
        Text(profile?.fullName ?? 'Usuario Fudi', style: FudiTypography.h3),
        const SizedBox(height: FudiSpacing.xs),
        Text(
          profile?.email ?? '',
          style: FudiTypography.bodyMedium.copyWith(
            color: FudiColors.mutedForeground,
          ),
        ),
        if (profile?.city != null) ...[
          const SizedBox(height: FudiSpacing.xs),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 14,
                color: FudiColors.mutedForeground,
              ),
              const SizedBox(width: 4),
              Text(profile!.city!, style: FudiTypography.bodySmall),
            ],
          ),
        ],
      ],
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
}

class _ProfileMenuSection extends StatelessWidget {
  const _ProfileMenuSection({required this.items});

  final List<_MenuItem> items;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: items.map((item) {
          return Column(
            children: [
              ListTile(
                leading: Icon(item.icon, color: FudiColors.primary),
                title: Text(item.label, style: FudiTypography.bodyLarge),
                trailing: const Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: FudiColors.mutedForeground,
                ),
                onTap: item.onTap,
              ),
              if (item != items.last) const Divider(height: 1),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _MenuItem {
  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
}

class _SignOutButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authController = ref.read(authControllerProvider.notifier);

    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () => _showSignOutDialog(context, authController),
        style: OutlinedButton.styleFrom(
          foregroundColor: FudiColors.destructive,
          side: const BorderSide(color: FudiColors.destructive),
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(FudiRadius.lg),
          ),
        ),
        child: Text(
          'Cerrar sesión',
          style: FudiTypography.labelMedium.copyWith(
            color: FudiColors.destructive,
          ),
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
