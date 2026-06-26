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
  const ConfirmationView({required this.offer, required this.result});

  final Offer offer;
  final ReservationSuccess result;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FudiColors.muted,
      body: SafeArea(
        child: Center(
          child: Container(
            margin: const EdgeInsets.all(FudiSpacing.lg),
            padding: const EdgeInsets.all(FudiSpacing.xl),
            decoration: BoxDecoration(
              color: FudiColors.background,
              borderRadius: BorderRadius.circular(FudiRadius.xxl),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x1A000000),
                  blurRadius: 24,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: const BoxDecoration(
                      color: Color(0xFFDCFCE7),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_circle_rounded,
                      size: 48,
                      color: Color(0xFF16A34A),
                    ),
                  ),
                  const SizedBox(height: FudiSpacing.lg),
                  Text(
                    '¡Reserva confirmada!',
                    style: FudiTypography.h2.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: FudiSpacing.sm),
                  Text(
                    'Tu pedido ha sido procesado exitosamente',
                    style: FudiTypography.bodyMedium.copyWith(
                      color: FudiColors.mutedForeground,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: FudiSpacing.xl),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(FudiSpacing.md),
                    decoration: BoxDecoration(
                      color: FudiColors.muted,
                      borderRadius: BorderRadius.circular(FudiRadius.xl),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Número de pedido',
                          style: FudiTypography.bodySmall,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          result.orderNumber,
                          style: FudiTypography.labelMedium.copyWith(
                            color: FudiColors.primary,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: FudiSpacing.lg),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(FudiSpacing.lg),
                    decoration: BoxDecoration(
                      color: FudiColors.background,
                      border: Border.all(color: FudiColors.primary, width: 2),
                      borderRadius: BorderRadius.circular(FudiRadius.xxl),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Código de recogida',
                          style: FudiTypography.labelSmall.copyWith(
                            color: FudiColors.mutedForeground,
                          ),
                        ),
                        const SizedBox(height: FudiSpacing.md),
                        Container(
                          padding: const EdgeInsets.all(FudiSpacing.xl),
                          decoration: BoxDecoration(
                            color: FudiColors.muted,
                            borderRadius: BorderRadius.circular(FudiRadius.lg),
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
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 6,
                            color: FudiColors.primary,
                          ),
                        ),
                        const SizedBox(height: FudiSpacing.sm),
                        Text(
                          'Muestra este código al recoger tu pedido',
                          style: FudiTypography.bodySmall.copyWith(
                            fontSize: 10,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: FudiSpacing.lg),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(FudiSpacing.md),
                    decoration: BoxDecoration(
                      color: FudiColors.background,
                      border: Border.all(color: FudiColors.borderSolid),
                      borderRadius: BorderRadius.circular(FudiRadius.xxl),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 20,
                              color: FudiColors.primary,
                            ),
                            const SizedBox(width: FudiSpacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Recoger en',
                                    style: FudiTypography.labelSmall,
                                  ),
                                  Text(
                                    offer.business.name,
                                    style: FudiTypography.bodyMedium,
                                  ),
                                  Text(
                                    offer.business.address,
                                    style: FudiTypography.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: FudiSpacing.md),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.schedule,
                              size: 20,
                              color: FudiColors.primary,
                            ),
                            const SizedBox(width: FudiSpacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Horario de recogida',
                                    style: FudiTypography.labelSmall,
                                  ),
                                  Text(
                                    'Antes de ${MaterialLocalizations.of(context).formatTimeOfDay(offer.pickupUntilTimeOfDay)}',
                                    style: FudiTypography.bodyMedium,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: FudiSpacing.lg),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(FudiSpacing.md),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDF4),
                      border: Border.all(color: const Color(0xFFBBF7D0)),
                      borderRadius: BorderRadius.circular(FudiRadius.lg),
                    ),
                    child: Text(
                      'Recibirás un correo con los detalles de tu pedido. Presenta el código de reserva al recoger.',
                      style: FudiTypography.bodySmall.copyWith(
                        color: const Color(0xFF15803D),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: FudiSpacing.xl),
                  FudiPressableScale(
                    onTap: () => context.go('/orders'),
                    child: Container(
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        color: FudiColors.primary,
                        borderRadius: BorderRadius.circular(FudiRadius.lg),
                      ),
                      child: Center(
                        child: Text(
                          'Ver mis pedidos',
                          style: FudiTypography.labelMedium.copyWith(
                            color: Colors.white,
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
                      height: 56,
                      decoration: BoxDecoration(
                        border: Border.all(color: FudiColors.primary),
                        borderRadius: BorderRadius.circular(FudiRadius.lg),
                      ),
                      child: Center(
                        child: Text(
                          'Buscar más ofertas',
                          style: FudiTypography.labelMedium.copyWith(color: FudiColors.primary),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
