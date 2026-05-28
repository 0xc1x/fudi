import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/ui/fudi_colors.dart';
import '../../../core/ui/atoms/icons/fudi_icons.dart';
import '../../../core/ui/fudi_spacing.dart';
import '../../../core/ui/fudi_typography.dart';
import '../../../core/ui/fudi_sticky_page_header.dart';
import '../../../core/ui/fudi_surface_card.dart';
import '../../../core/ui/fudi_bottom_action_bar.dart';
import 'profile_providers.dart';

class PaymentMethodsScreen extends ConsumerWidget {
  const PaymentMethodsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paymentsAsync = ref.watch(paymentMethodsProvider);

    return Scaffold(
      appBar: const FudiStickyPageHeader(title: 'Métodos de Pago'),
      body: paymentsAsync.when(
        data: (methods) {
          if (methods.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(FudiIcons.creditCard, size: 64, color: FudiColors.mutedForeground),
                  const SizedBox(height: FudiSpacing.md),
                  Text('No tienes tarjetas guardadas', style: FudiTypography.bodyLarge),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(FudiSpacing.lg),
            itemCount: methods.length,
            separatorBuilder: (_, _) => const SizedBox(height: FudiSpacing.md),
            itemBuilder: (context, index) {
              final method = methods[index];
              return FudiSurfaceCard(
                child: ListTile(
                  leading: Icon(_getCardIcon(method.brand), color: FudiColors.primary),
                  title: Row(
                    children: [
                      Text('•••• ${method.last4}', style: FudiTypography.labelSmall),
                      if (method.isDefault) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: FudiColors.secondary,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text('PRINCIPAL', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: FudiColors.primary)),
                        ),
                      ],
                    ],
                  ),
                  subtitle: Text(method.brand.toUpperCase(), style: FudiTypography.bodySmall),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: FudiColors.destructive),
                    onPressed: () => _deleteMethod(ref, method.id),
                  ),
                  onTap: () => _setDefault(ref, method.id),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
      bottomNavigationBar: FudiBottomActionBar(
        child: FilledButton(
          onPressed: () => _addMethod(context),
          style: FilledButton.styleFrom(
            backgroundColor: FudiColors.primary,
            minimumSize: const Size.fromHeight(56),
          ),
          child: const Text('Agregar tarjeta'),
        ),
      ),
    );
  }

  IconData _getCardIcon(String brand) {
    return brand.toLowerCase() == 'visa' ? Icons.credit_card : Icons.credit_card;
  }

  void _deleteMethod(WidgetRef ref, String id) {
    ref.read(consumerProfileRepositoryProvider).deletePaymentMethod(id);
    ref.invalidate(paymentMethodsProvider);
  }

  void _setDefault(WidgetRef ref, String id) {
    ref.read(consumerProfileRepositoryProvider).setDefaultPaymentMethod(id);
    ref.invalidate(paymentMethodsProvider);
  }

  void _addMethod(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Funcionalidad en desarrollo')));
  }
}
