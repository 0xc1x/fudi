import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/ui/fudi_colors.dart';
import '../business_providers.dart';
import '../components/business_app_bar.dart';
import '../components/no_business_prompt.dart';
import '../components/orders_content.dart';

class BusinessOrdersScreen extends ConsumerWidget {
  const BusinessOrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final businessAsync = ref.watch(currentBusinessProvider);

    return Scaffold(
      backgroundColor: FudiColors.background,
      body: businessAsync.when(
        data: (business) {
          if (business == null) return const NoBusinessPrompt();

          final allBusinessesAsync = ref.watch(userBusinessesProvider);
          final allBusinesses = allBusinessesAsync.asData?.value ?? [business];
          final ordersStream = ref.watch(
            businessOrdersStreamProvider(business.id),
          );

          return Scaffold(
            backgroundColor: FudiColors.background,
            appBar: PreferredSize(
              preferredSize: const Size.fromHeight(kToolbarHeight + 20),
              child: BusinessAppBar(
                business: business,
                allBusinesses: allBusinesses,
                title: 'Pedidos',
              ),
            ),
            body: ordersStream.when(
              data: (orders) =>
                  OrdersContent(orders: orders, businessId: business.id),
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          );
        },
        loading: () =>
            const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
