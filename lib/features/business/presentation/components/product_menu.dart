import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/ui/atoms/icons/fudi_icons.dart';
import '../../../../core/ui/fudi_colors.dart';
import '../../../../core/ui/fudi_pressable_scale.dart';
import '../../../../core/ui/fudi_spacing.dart';
import '../../../offers/domain/offer.dart';
import '../business_providers.dart';

class ProductMenu extends ConsumerWidget {
  const ProductMenu({
    super.key,
    required this.offer,
    this.child,
  });

  final Offer offer;
  final Widget? child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopupMenuButton<String>(
      icon: child == null
          ? const Icon(
              Icons.more_vert,
              color: FudiColors.mutedForeground,
              size: 20,
            )
          : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(FudiRadius.md),
      ),
      child: child,
      onSelected: (value) async {
        if (value == 'toggle') {
          await ref
              .read(businessCatalogRepositoryProvider)
              .toggleOfferStatus(offer.id, !offer.isActive);
          ref.invalidate(businessOffersProvider(offer.businessId));
        } else if (value == 'edit') {
          if (context.mounted) {
            context.push('/business/products/edit/${offer.id}');
          }
        } else if (value == 'delete') {
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Eliminar producto'),
              content: const Text(
                '¿Estás seguro de que deseas eliminar este producto?',
              ),
              actions: [
                FudiPressableScale(
                  onTap: () => Navigator.pop(ctx, false),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Text('Cancelar'),
                  ),
                ),
                FudiPressableScale(
                  onTap: () => Navigator.pop(ctx, true),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Text(
                      'Eliminar',
                      style: TextStyle(color: FudiColors.destructive),
                    ),
                  ),
                ),
              ],
            ),
          );
          if (confirmed == true) {
            await ref
                .read(businessCatalogRepositoryProvider)
                .deleteOffer(offer.id);
            ref.invalidate(businessOffersProvider(offer.businessId));
          }
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'toggle',
          child: Row(
            children: [
              Icon(offer.isActive ? FudiIcons.eyeOff : FudiIcons.eye, size: 18),
              const SizedBox(width: 8),
              Text(offer.isActive ? 'Desactivar' : 'Activar'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit_rounded, size: 18),
              SizedBox(width: 8),
              Text('Editar'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(
                Icons.delete_outline_rounded,
                size: 18,
                color: FudiColors.destructive,
              ),
              SizedBox(width: 8),
              Text('Eliminar', style: TextStyle(color: FudiColors.destructive)),
            ],
          ),
        ),
      ],
    );
  }
}
