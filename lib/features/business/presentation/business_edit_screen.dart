import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/ui/fudi_colors.dart';
import '../../../core/ui/fudi_spacing.dart';
import '../../../core/ui/fudi_typography.dart';
import '../domain/business_profile.dart';
import 'business_profile_providers.dart';
import 'business_providers.dart';
import 'components/no_business_prompt.dart';

class BusinessEditScreen extends ConsumerStatefulWidget {
  const BusinessEditScreen({super.key});

  @override
  ConsumerState<BusinessEditScreen> createState() => _BusinessEditScreenState();
}

class _BusinessEditScreenState extends ConsumerState<BusinessEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _description = TextEditingController();
  final _address = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _website = TextEditingController();
  var _loaded = false;
  var _saving = false;

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    _address.dispose();
    _phone.dispose();
    _email.dispose();
    _website.dispose();
    super.dispose();
  }

  void _hydrate(BusinessProfile business) {
    if (_loaded) return;
    _loaded = true;
    _name.text = business.name;
    _description.text = business.description ?? '';
    _address.text = business.address ?? '';
    _phone.text = business.phone ?? '';
    _email.text = business.email ?? '';
    _website.text = business.website ?? '';
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final business = await ref.read(currentBusinessProvider.future);
      if (business == null) return;

      final updated = BusinessProfile(
        id: business.id,
        name: _name.text.trim(),
        type: business.type,
        address: _address.text.trim(),
        rating: business.rating,
        imageUrl: business.imageUrl,
        coverImageUrl: business.coverImageUrl,
        description: _description.text.trim().isEmpty
            ? null
            : _description.text.trim(),
        phone: _phone.text.trim().isEmpty ? null : _phone.text.trim(),
        email: _email.text.trim().isEmpty ? null : _email.text.trim(),
        website: _website.text.trim().isEmpty ? null : _website.text.trim(),
        latitude: business.latitude,
        longitude: business.longitude,
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
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final businessAsync = ref.watch(currentBusinessProvider);
    return Scaffold(
      backgroundColor: FudiColors.background,
      appBar: AppBar(
        title: const Text('Editar negocio', style: FudiTypography.h4),
      ),
      body: businessAsync.when(
        data: (business) {
          if (business == null) return const NoBusinessPrompt();
          _hydrate(business);
          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(FudiSpacing.lg),
              children: [
                _field('Nombre', _name),
                _field(
                  'Descripción',
                  _description,
                  required: false,
                  maxLines: 3,
                ),
                _field('Dirección', _address),
                _field('Teléfono', _phone, required: false),
                _field('Email', _email, required: false),
                _field('Sitio web', _website, required: false),
                const SizedBox(height: FudiSpacing.lg),
                FilledButton(
                  onPressed: _saving ? null : _save,
                  child: Text(_saving ? 'Guardando...' : 'Guardar cambios'),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
      ),
    );
  }

  Widget _field(
    String label,
    TextEditingController controller, {
    bool required = true,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: FudiSpacing.md),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(labelText: label),
        validator: required
            ? (value) => value == null || value.trim().isEmpty
                  ? 'Campo requerido'
                  : null
            : null,
      ),
    );
  }
}
