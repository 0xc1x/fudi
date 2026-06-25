import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/ui/fudi_colors.dart';
import '../../../../core/ui/fudi_spacing.dart';
import '../../../../core/ui/fudi_typography.dart';
import '../../../../core/ui/atoms/icons/fudi_icons.dart';
import '../../../auth/domain/user_profile.dart';
import '../../../auth/presentation/auth_state_provider.dart';
import '../../../profile/domain/user_order.dart';
import '../../../profile/presentation/profile_providers.dart';
import '../welcome_message.dart';

class WelcomeBanner extends ConsumerStatefulWidget {
  const WelcomeBanner({super.key});

  @override
  ConsumerState<WelcomeBanner> createState() => _WelcomeBannerState();
}

class _WelcomeBannerState extends ConsumerState<WelcomeBanner> {
  late final int _selectedStatIndex;

  @override
  void initState() {
    super.initState();
    _selectedStatIndex = Random().nextInt(3);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authSessionNotifierProvider);
    final profile = authState.profile;

    if (profile == null || authState.role != UserRole.user) {
      return const SizedBox.shrink();
    }

    final data = WelcomeMessage.generate(profile: profile, now: DateTime.now());
    const double bannerHeight = 100;

    return Container(
      margin: const EdgeInsets.fromLTRB(
        FudiSpacing.lg,
        FudiSpacing.md,
        FudiSpacing.lg,
        FudiSpacing.sm,
      ),
      height: bannerHeight,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(data.greeting, style: FudiTypography.h2),
                const SizedBox(height: 2),
                Text(
                  data.displayName,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: FudiColors.secondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(data.contextualMessage, style: FudiTypography.bodySmall),
              ],
            ),
          ),
          const SizedBox(width: FudiSpacing.sm),
          SizedBox(
            width: bannerHeight,
            height: bannerHeight,
            child: _buildStatCircle(ref.watch(userStatsProvider)),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCircle(AsyncValue<UserStats> statsAsync) {
    return statsAsync.when(
      data: (stats) => _StatCircle(statIndex: _selectedStatIndex, stats: stats),
      loading: () => const SizedBox(
        height: 100,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      ),
      error: (_, _) => const SizedBox.shrink(),
    );
  }
}

class _StatCircle extends StatelessWidget {
  const _StatCircle({required this.statIndex, required this.stats});

  final int statIndex;
  final UserStats stats;

  @override
  Widget build(BuildContext context) {
    final stat = _getStatData();

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.maxWidth;
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: FudiColors.secondary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: FudiColors.secondary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  FudiIcons.leaf,
                  size: 16,
                  color: FudiColors.secondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                stat.value,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: FudiColors.accent,
                ),
              ),
              Text(
                stat.label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 10,
                  color: FudiColors.secondary,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  _StatInfo _getStatData() {
    switch (statIndex) {
      case 0:
        return _StatInfo(
          icon: FudiIcons.award,
          value: stats.totalSaved >= 1000
              ? '\$${(stats.totalSaved / 1000).toStringAsFixed(1)}k'
              : '\$${stats.totalSaved.toStringAsFixed(0)}',
          label: 'Ahorrado',
        );
      case 1:
        return _StatInfo(
          icon: FudiIcons.package_,
          value: '${stats.totalOrders}',
          label: 'Pedidos',
        );
      default:
        return _StatInfo(
          icon: FudiIcons.leaf,
          value: '${stats.co2SavedKg.toStringAsFixed(1)} kg',
          label: 'CO\u2082 evitado',
        );
    }
  }
}

class _StatInfo {
  final IconData icon;
  final String value;
  final String label;
  const _StatInfo({
    required this.icon,
    required this.value,
    required this.label,
  });
}
