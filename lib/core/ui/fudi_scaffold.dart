import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'fudi_bottom_nav.dart';
import 'fudi_logo.dart';
import 'fudi_spacing.dart';
import 'atoms/icons/fudi_icons.dart';

/// Scaffold base para todas las pantallas de Fudi.
///
/// Incluye:
/// - Manejo automático de banner offline.
/// - Navegación inferior opcional.
/// - AppBar preconfigurada con el logo.
class FudiScaffold extends ConsumerWidget {
  const FudiScaffold({
    super.key,
    required this.body,
    this.title,
    this.showBottomNav = false,
    this.showAppBar = true,
    this.floatingActionButton,
    this.actions,
  });

  final Widget body;
  final String? title;
  final bool showBottomNav;
  final bool showAppBar;
  final Widget? floatingActionButton;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: showAppBar ? _buildAppBar(context) : null,
      body: Column(
        children: [
          const _OfflineBanner(),
          Expanded(child: body),
        ],
      ),
      bottomNavigationBar: showBottomNav ? const FudiBottomNav() : null,
      floatingActionButton: floatingActionButton,
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: title != null
          ? Text(title!)
          : const FudiLogo(variant: FudiLogoVariant.icon),
      actions: actions,
    );
  }
}

class _OfflineBanner extends StatefulWidget {
  const _OfflineBanner();

  @override
  State<_OfflineBanner> createState() => _OfflineBannerState();
}

class _OfflineBannerState extends State<_OfflineBanner> {
  bool _isOffline = false;
  late final StreamSubscription<InternetStatus> _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = InternetConnection().onStatusChange.listen((status) {
      final isOffline = status == InternetStatus.disconnected;
      if (_isOffline != isOffline) {
        setState(() => _isOffline = isOffline);
      }
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isOffline) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      color: Theme.of(context).colorScheme.errorContainer,
      padding: const EdgeInsets.symmetric(
        vertical: FudiSpacing.xs,
        horizontal: FudiSpacing.lg,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            FudiIcons.offline,
            size: 16,
            color: Theme.of(context).colorScheme.onErrorContainer,
          ),
          const SizedBox(width: 8),
          Text(
            'Sin conexión a Internet',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.onErrorContainer,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
