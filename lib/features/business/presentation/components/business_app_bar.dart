import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/ui/fudi_colors.dart';
import '../../../../core/ui/fudi_logo.dart';
import '../../../../core/ui/fudi_spacing.dart';
import '../../../../core/ui/fudi_typography.dart';
import '../../domain/business_profile.dart';
import '../business_providers.dart';
import 'business_branch_selector.dart';
import 'business_selector.dart';

class BusinessAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const BusinessAppBar({
    super.key,
    required this.business,
    required this.allBusinesses,
    this.title = 'Mis Productos',
  });

  final BusinessProfile business;
  final List<BusinessProfile> allBusinesses;
  final String title;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 20);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (allBusinesses.length <= 1) {
      final locationsAsync = ref.watch(businessLocationsProvider(business.id));
      return AppBar(
        backgroundColor: FudiColors.card,
        elevation: 0,
        scrolledUnderElevation: 0,
        toolbarHeight: kToolbarHeight + 20,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: FudiTypography.h2.copyWith(
                color: FudiColors.foreground,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            locationsAsync.when(
              data: (locations) => BusinessBranchSelector(locations: locations),
              loading: () => const SizedBox.shrink(),
              error: (_, _) => const SizedBox.shrink(),
            ),
          ],
        ),
        centerTitle: false,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: FudiSpacing.md),
            child: FudiLogo(
              variant: FudiLogoVariant.wordmark,
              size: FudiLogoSize.xxxl,
            ),
          ),
        ],
      );
    }

    // Multi-business path: show BusinessSelector in the title
    return AppBar(
      backgroundColor: FudiColors.card,
      elevation: 0,
      scrolledUnderElevation: 0,
      toolbarHeight: kToolbarHeight + 20,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: FudiTypography.h2.copyWith(
              color: FudiColors.foreground,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          BusinessSelector(
            business: business,
            allBusinesses: allBusinesses,
            onSelected: (id) =>
                ref.read(selectedBusinessIdProvider.notifier).select(id),
          ),
        ],
      ),
      centerTitle: false,
      actions: const [
        Padding(
          padding: EdgeInsets.only(right: FudiSpacing.md),
          child: FudiLogo(variant: FudiLogoVariant.icon, size: FudiLogoSize.md),
        ),
      ],
    );
  }
}
