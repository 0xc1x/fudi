import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../../../core/error/user_friendly_message.dart';
import '../../../core/ui/atoms/icons/fudi_icons.dart';
import '../../../core/ui/fudi_colors.dart';
import '../../../core/ui/fudi_pressable_scale.dart';
import '../../../core/ui/fudi_spacing.dart';
import '../../../core/ui/fudi_theme.dart';
import '../../../core/ui/fudi_typography.dart';
import '../domain/business_profile.dart';
import 'business_profile_providers.dart';
import 'business_providers.dart';

const _businessTypes = [
  ('restaurant', 'Restaurante', Icons.restaurant_rounded),
  ('bakery', 'Panadería', Icons.bakery_dining_rounded),
  ('cafe', 'Cafetería', Icons.local_cafe_rounded),
  ('grocery', 'Supermercado', Icons.shopping_bag_outlined),
  ('other', 'Otro', Icons.storefront_rounded),
];

class BusinessEditScreen extends ConsumerStatefulWidget {
  const BusinessEditScreen({super.key});

  @override
  ConsumerState<BusinessEditScreen> createState() => _BusinessEditScreenState();
}

class _BusinessEditScreenState extends ConsumerState<BusinessEditScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _websiteController = TextEditingController();
  final _addressController = TextEditingController();

  String _selectedType = 'restaurant';
  bool _loaded = false;
  bool _saving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _websiteController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _hydrate(BusinessProfile business) {
    if (_loaded) return;
    _loaded = true;
    _nameController.text = business.name;
    _descriptionController.text = business.description ?? '';
    _phoneController.text = business.phone ?? '';
    _emailController.text = business.email ?? '';
    _websiteController.text = business.website ?? '';
    _addressController.text = business.address ?? '';
    _selectedType = business.type;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    try {
      final business = await ref.read(currentBusinessProvider.future);
      if (business == null) return;

      final updated = BusinessProfile(
        id: business.id,
        name: _nameController.text.trim(),
        type: _selectedType,
        address: _addressController.text.trim(),
        rating: business.rating,
        imageUrl: business.imageUrl,
        coverImageUrl: business.coverImageUrl,
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        phone: _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
        email: _emailController.text.trim().isEmpty
            ? null
            : _emailController.text.trim(),
        website: _websiteController.text.trim().isEmpty
            ? null
            : _websiteController.text.trim(),
        latitude: business.latitude,
        longitude: business.longitude,
        zone: business.zone,
        reviewCount: business.reviewCount,
        totalRescued: business.totalRescued,
        memberSince: business.memberSince,
        hours: business.hours,
        reviews: business.reviews,
      );

      await ref
          .read(businessProfileRepositoryProvider)
          .updateBusiness(updated);

      ref.invalidate(currentBusinessProvider);
      if (mounted) context.pop();
    } catch (e, st) {
      unawaited(Sentry.captureException(e, stackTrace: st));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(userFriendlyMessage(e)),
            backgroundColor: FudiColors.destructiveVibrant,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final themeExt = theme.extension<FudiThemeExtension>();
    final businessAsync = ref.watch(currentBusinessProvider);
    final business = businessAsync.asData?.value;
    if (business != null) _hydrate(business);

    if (business == null && !businessAsync.isLoading) {
      return Scaffold(
        backgroundColor: colorScheme.surface,
        appBar: _buildAppBar(),
        body: const Center(child: Text('No se encontró el negocio')),
      );
    }

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: _buildAppBar(),
      body: businessAsync.isLoading && !_loaded
          ? const Center(child: CircularProgressIndicator())
          : GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: FudiSpacing.lg,
                  vertical: FudiSpacing.xl,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Detalles Básicos',
                        style: FudiTypography.bodyMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: FudiSpacing.md),
                      _buildField(
                        label: 'Nombre del negocio',
                        controller: _nameController,
                        hint: 'Ej: Panadería La Europea',
                        icon: FudiIcons.storefront,
                        isRequired: true,
                      ),
                      const SizedBox(height: FudiSpacing.lg),
                      Text(
                        'Tipo de Establecimiento',
                        style: FudiTypography.bodySmall.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: FudiSpacing.sm),
                      _buildBusinessTypeSelector(),
                      const SizedBox(height: FudiSpacing.xl),
                      Text(
                        'Información del Negocio',
                        style: FudiTypography.bodyMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: FudiSpacing.md),
                      _buildField(
                        label: 'Descripción',
                        controller: _descriptionController,
                        hint: 'Describe tu negocio, horarios, servicios...',
                        icon: Icons.description_outlined,
                        maxLines: 4,
                      ),
                      const SizedBox(height: FudiSpacing.lg),
                      _buildField(
                        label: 'Dirección',
                        controller: _addressController,
                        hint: 'Ej: Av. República 123 y Amazonas',
                        icon: FudiIcons.mapPin,
                      ),
                      const SizedBox(height: FudiSpacing.lg),
                      _buildField(
                        label: 'Teléfono de contacto',
                        controller: _phoneController,
                        hint: 'Ej: +593 98 765 4321',
                        icon: FudiIcons.phone,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'[+\d\s()-]'),
                          ),
                        ],
                      ),
                      const SizedBox(height: FudiSpacing.lg),
                      _buildField(
                        label: 'Correo electrónico',
                        controller: _emailController,
                        hint: 'Ej: contacto@negocio.com',
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: FudiSpacing.lg),
                      _buildField(
                        label: 'Sitio web',
                        controller: _websiteController,
                        hint: 'Ej: https://www.negocio.com',
                        icon: Icons.language_outlined,
                        keyboardType: TextInputType.url,
                      ),
                      const SizedBox(height: 140),
                    ],
                  ),
                ),
              ),
            ),
      bottomSheet: Container(
        padding: const EdgeInsets.only(
          left: FudiSpacing.lg,
          right: FudiSpacing.lg,
          top: FudiSpacing.md,
          bottom: FudiSpacing.xl,
        ),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: colorScheme.onSurface.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, -4),
            )
          ],
          border: Border(
            top: BorderSide(color: themeExt?.border ?? FudiColors.border, width: 0.5),
          ),
        ),
        child: SizedBox(
          width: double.infinity,
          child: FudiPressableScale(
            onTap: _saving ? null : _save,
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                color: _saving ? (themeExt?.mutedBackground ?? FudiColors.muted) : FudiColors.primary,
                borderRadius: BorderRadius.circular(FudiRadius.md),
              ),
              alignment: Alignment.center,
              child: _saving
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: FudiColors.primaryForeground,
                      ),
                    )
                  : Text(
                      'Guardar Cambios',
                      style: FudiTypography.bodyMedium.copyWith(
                        color: FudiColors.primaryForeground,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final cs = Theme.of(context).colorScheme;
    return AppBar(
      leading: Center(
        child: FudiPressableScale(
          onTap: () => context.pop(),
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: cs.surface,
              shape: BoxShape.circle,
            ),
            child: Icon(
              FudiIcons.chevronLeft,
              size: 18,
              color: cs.onSurface,
            ),
          ),
        ),
      ),
      title: Text(
        'Editar negocio',
        style: FudiTypography.h4.copyWith(fontWeight: FontWeight.bold),
      ),
      backgroundColor: cs.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
    );
  }

  Widget _buildBusinessTypeSelector() {
    final cs = Theme.of(context).colorScheme;
    final tex = Theme.of(context).extension<FudiThemeExtension>();
    final borderColor = tex?.border ?? FudiColors.border;
    return SizedBox(
      height: 42,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _businessTypes.length,
        itemBuilder: (context, index) {
          final type = _businessTypes[index];
          final isSelected = _selectedType == type.$1;
          return Padding(
            padding: const EdgeInsets.only(right: FudiSpacing.sm),
            child: ChoiceChip(
              label: Row(
                children: [
                  Icon(
                    type.$3,
                    size: 16,
                    color: isSelected
                        ? FudiColors.primaryForeground
                        : cs.onSurfaceVariant,
                  ),
                  const SizedBox(width: 6),
                  Text(type.$2),
                ],
              ),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() => _selectedType = type.$1);
                }
              },
              selectedColor: FudiColors.primary,
              backgroundColor: cs.surface,
              labelStyle: FudiTypography.bodySmall.copyWith(
                color: isSelected ? FudiColors.primaryForeground : cs.onSurface,
                fontWeight:
                    isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(FudiRadius.sm),
                side: BorderSide(
                  color: isSelected ? FudiColors.primary : borderColor,
                ),
              ),
              showCheckmark: false,
              elevation: 0,
              pressElevation: 0,
            ),
          );
        },
      ),
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required String hint,
    IconData? icon,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    int maxLines = 1,
    bool isRequired = false,
  }) {
    final cs = Theme.of(context).colorScheme;
    final tex = Theme.of(context).extension<FudiThemeExtension>();
    final borderColor = tex?.border ?? FudiColors.border;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label${isRequired ? ' *' : ''}',
          style: FudiTypography.bodySmall.copyWith(
            fontWeight: FontWeight.w600,
            color: cs.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          maxLines: maxLines,
          style: FudiTypography.bodyMedium.copyWith(
            color: cs.onSurface,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: FudiTypography.bodyMedium.copyWith(
              color: cs.onSurfaceVariant.withValues(alpha: 0.7),
            ),
            filled: true,
            fillColor: cs.surface,
            prefixIcon: icon != null
                ? Icon(
                    icon,
                    size: 18,
                    color: cs.onSurfaceVariant.withValues(alpha: 0.7),
                  )
                : null,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: FudiSpacing.md,
              vertical: FudiSpacing.sm + 2,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(FudiRadius.sm),
              borderSide: BorderSide(color: borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(FudiRadius.sm),
              borderSide: const BorderSide(color: FudiColors.primary, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(FudiRadius.sm),
              borderSide: const BorderSide(color: FudiColors.destructiveVibrant),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(FudiRadius.sm),
              borderSide: const BorderSide(color: FudiColors.destructiveVibrant, width: 1.5),
            ),
          ),
          validator: (value) =>
              (value == null || value.trim().isEmpty) && isRequired
                  ? 'Este campo es obligatorio'
                  : null,
        ),
      ],
    );
  }
}
