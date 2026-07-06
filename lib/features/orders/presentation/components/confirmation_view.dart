import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/ui/atoms/pickup_code_qr.dart';
import '../../../../core/ui/fudi_colors.dart';
import '../../../../core/ui/fudi_pressable_scale.dart';
import '../../../../core/ui/fudi_spacing.dart';
import '../../../../core/ui/fudi_typography.dart';
import '../../../offers/domain/offer.dart';
import '../../domain/reservation_result.dart';

class ConfirmationView extends StatelessWidget {
  const ConfirmationView({
    super.key,
    required this.offer,
    required this.result,
  });

  final Offer offer;
  final ReservationSuccess result;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FudiColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(FudiSpacing.xl),
          child: Column(
            children: [
              const SizedBox(height: FudiSpacing.md),
              const Center(
                child: Icon(
                  Icons.check_circle_rounded,
                  size: 54,
                  color: FudiColors.ecoGreen,
                ),
              ),
              const SizedBox(height: FudiSpacing.sm),
              Text(
                '¡Reserva Confirmada!',
                style: FudiTypography.h3.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                'Tu comida ha sido salvada con éxito',
                style: FudiTypography.bodyMedium.copyWith(
                  color: FudiColors.mutedForeground,
                ),
              ),
              const SizedBox(height: FudiSpacing.xl),

              // Ticket de Recogida QR
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(FudiSpacing.xl),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: FudiColors.borderSolid, width: 1.5),
                ),
                child: Column(
                  children: [
                    Text(
                      'CÓDIGO DE RECOGIDA',
                      style: FudiTypography.labelSmall.copyWith(
                        color: FudiColors.mutedForeground,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: FudiSpacing.md),
                    Container(
                      padding: const EdgeInsets.all(FudiSpacing.md),
                      decoration: BoxDecoration(
                        color: FudiColors.muted.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: PickupCodeQr(
                        orderId: result.orderId,
                        pickupCode: result.pickupCode,
                      ),
                    ),
                    const SizedBox(height: FudiSpacing.md),
                    Text(
                      result.pickupCode,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 6,
                        color: FudiColors.primary,
                      ),
                    ),
                    Text(
                      'Orden: #${result.orderNumber}',
                      style: FudiTypography.bodySmall.copyWith(
                        color: FudiColors.mutedForeground,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: FudiSpacing.md),

              // Datos del Negocio
              Container(
                padding: const EdgeInsets.all(FudiSpacing.md),
                decoration: BoxDecoration(
                  color: FudiColors.muted.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.storefront_rounded,
                      color: FudiColors.primary,
                      size: 20,
                    ),
                    const SizedBox(width: FudiSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            offer.business.name,
                            style: FudiTypography.labelSmall.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            offer.business.address,
                            style: FudiTypography.bodySmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: FudiSpacing.xl),

              // Botonera de flujo directo
              FudiPressableScale(
                onTap: () => context.go('/orders'),
                child: Container(
                  width: double.infinity,
                  height: 48,
                  decoration: BoxDecoration(
                    color: FudiColors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      'Ver mis pedidos',
                      style: FudiTypography.labelSmall.copyWith(
                        color: FudiColors.primaryForeground,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: FudiSpacing.sm),
              FudiPressableScale(
                onTap: () => context.go('/'),
                child: Container(
                  width: double.infinity,
                  height: 48,
                  decoration: BoxDecoration(
                    border: Border.all(color: FudiColors.borderSolid),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      'Buscar más ofertas',
                      style: FudiTypography.labelSmall.copyWith(
                        color: FudiColors.mutedForeground,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
