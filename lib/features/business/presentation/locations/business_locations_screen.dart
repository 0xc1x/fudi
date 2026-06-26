import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/ui/fudi_colors.dart';
import '../business_providers.dart';
import '../components/locations_content.dart';
import '../components/no_business_prompt.dart';

class BusinessLocationsScreen extends ConsumerWidget {
  const BusinessLocationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final businessAsync = ref.watch(currentBusinessProvider);
    return Scaffold(
      backgroundColor: FudiColors.muted,
      body: businessAsync.when(
        data: (business) {
          if (business == null) return const NoBusinessPrompt();
          final locationsAsync = ref.watch(
            businessLocationsProvider(business.id),
          );
          return locationsAsync.when(
            data: (locations) =>
                LocationsContent(business: business, locations: locations),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('$e')),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
      ),
    );
  }
}
