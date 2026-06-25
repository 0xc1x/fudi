import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/route_names.dart';
import '../../../../core/ui/atoms/icons/fudi_icons.dart';
import '../../../../core/ui/fudi_colors.dart';
import '../../../../core/ui/fudi_logo.dart';
import '../../../../core/ui/fudi_pressable_scale.dart';
import '../../../../core/ui/fudi_spacing.dart';
import '../../../../core/ui/fudi_typography.dart';

class GuestWelcomeView extends StatelessWidget {
  const GuestWelcomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FudiColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: FudiSpacing.xl,
              vertical: FudiSpacing.xxl,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: FudiSpacing.xl),
                const FudiLogo(
                  variant: FudiLogoVariant.wordmark,
                  size: FudiLogoSize.xxxl,
                ),
                const SizedBox(height: FudiSpacing.sm),
                Text(
                  'Buena comida, mejores decisiones',
                  style: FudiTypography.bodyMedium.copyWith(
                    color: FudiColors.mutedForeground,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: FudiSpacing.xxl * 1.5),
                BenefitCard(
                  icon: FudiIcons.leaf,
                  title: 'Evita el desperdicio de comida',
                  description:
                      'Rescata paquetes de comida en perfecto estado de tus comercios locales favoritos.',
                ),
                const SizedBox(height: FudiSpacing.md),
                BenefitCard(
                  icon: FudiIcons.award,
                  title: 'Ahorra en cada compra',
                  description:
                      'Disfruta de excelentes platos y productos de calidad con descuentos de hasta el 70%.',
                ),
                const SizedBox(height: FudiSpacing.md),
                BenefitCard(
                  icon: FudiIcons.mapPin,
                  title: 'Apoya a negocios locales',
                  description:
                      'Conéctate con restaurantes, panaderías y supermercados de tu zona.',
                ),
                const SizedBox(height: FudiSpacing.xxl * 1.5),
                FudiPressableScale(
                  onTap: () => context.push(RouteNames.loginPath),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: FudiColors.primary,
                      borderRadius: BorderRadius.circular(FudiRadius.xl),
                    ),
                    child: const Center(
                      child: Text(
                        'Iniciar sesión',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: FudiSpacing.md),
                FudiPressableScale(
                  onTap: () => context.push(RouteNames.signupPath),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(FudiRadius.xl),
                      border: Border.all(color: FudiColors.primary, width: 2),
                    ),
                    child: const Center(
                      child: Text(
                        'Crear una cuenta',
                        style: TextStyle(
                          color: FudiColors.primary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: FudiSpacing.xl),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class BenefitCard extends StatelessWidget {
  const BenefitCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(FudiSpacing.lg),
      decoration: BoxDecoration(
        color: FudiColors.background,
        borderRadius: BorderRadius.circular(FudiRadius.xl),
        border: Border.all(color: FudiColors.borderSolid),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(FudiSpacing.sm),
            decoration: BoxDecoration(
              color: FudiColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: FudiColors.primary, size: 24),
          ),
          const SizedBox(width: FudiSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: FudiTypography.labelSmall.copyWith(
                    fontWeight: FontWeight.bold,
                    color: FudiColors.foreground,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: FudiTypography.bodySmall.copyWith(
                    color: FudiColors.mutedForeground,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
