import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/ui/fudi_colors.dart';

import '../business_providers.dart';
import '../components/no_business_prompt.dart';
import '../components/business_app_bar.dart';
import '../components/business_products_content.dart';

class BusinessProductsScreen extends ConsumerWidget {
  const BusinessProductsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final businessAsync = ref.watch(currentBusinessProvider);

    return Scaffold(
      backgroundColor: FudiColors.muted,
      body: businessAsync.when(
        data: (business) {
          if (business == null) return const NoBusinessPrompt();

          final allBusinessesAsync = ref.watch(userBusinessesProvider);
          final offersAsync = ref.watch(businessOffersProvider(business.id));
          final allBusinesses = allBusinessesAsync.asData?.value ?? [business];

          return Scaffold(
            backgroundColor: FudiColors.muted,
            appBar: PreferredSize(
              preferredSize: const Size.fromHeight(kToolbarHeight + 20),
              child: BusinessAppBar(
                business: business,
                allBusinesses: allBusinesses,
              ),
            ),
            body: offersAsync.when(
              data: (offers) => BusinessProductsContent(
                business: business,
                allBusinesses: allBusinesses,
                offers: offers,
              ),
              loading: () => BusinessProductsContent(
                business: business,
                allBusinesses: allBusinesses,
                offers: const [],
                isLoading: true,
              ),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          );
        },
        loading: () =>
            const Scaffold(body: Center(child: CircularProgressIndicator())),
        error: (e, _) => Scaffold(body: Center(child: Text('Error: $e'))),
      ),
    );
  }
}
