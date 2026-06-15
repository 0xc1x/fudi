import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/ui/fudi_colors.dart';
import '../../../../core/ui/fudi_spacing.dart';
import '../../../../core/ui/fudi_typography.dart';
import '../../domain/business_location.dart';
import '../business_providers.dart';

class BusinessLocationEditScreen extends ConsumerStatefulWidget {
  const BusinessLocationEditScreen({this.locationId, super.key});

  final String? locationId;

  @override
  ConsumerState<BusinessLocationEditScreen> createState() =>
      _BusinessLocationEditScreenState();
}

class _BusinessLocationEditScreenState
    extends ConsumerState<BusinessLocationEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _address = TextEditingController();
  final _phone = TextEditingController();
  bool _loaded = false;
  bool _saving = false;
  bool _isActive = true;

  @override
  void dispose() {
    _name.dispose();
    _address.dispose();
    _phone.dispose();
    super.dispose();
  }

  void _hydrate(BusinessLocation location) {
    if (_loaded) return;
    _loaded = true;
    _name.text = location.name;
    _address.text = location.address;
    _phone.text = location.phone ?? '';
    _isActive = location.isActive;
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.locationId != null;
    final locationAsync = isEdit
        ? ref.watch(businessLocationProvider(widget.locationId!))
        : null;

    return Scaffold(
      backgroundColor: FudiColors.background,
      appBar: AppBar(
        title: Text(
          isEdit ? 'Editar local' : 'Nuevo local',
          style: FudiTypography.h4,
        ),
      ),
      body:
          locationAsync?.when(
            data: (location) {
              _hydrate(location);
              return _buildForm(location: location);
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('$e')),
          ) ??
          _buildForm(),
    );
  }

  Widget _buildForm({BusinessLocation? location}) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(FudiSpacing.lg),
        children: [
          _field('Nombre del local', _name),
          _field('Dirección', _address),
          _field('Teléfono', _phone, required: false),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Local activo'),
            value: _isActive,
            onChanged: (value) => setState(() => _isActive = value),
          ),
          const SizedBox(height: FudiSpacing.lg),
          FilledButton(
            onPressed: _saving ? null : () => _save(location),
            child: Text(_saving ? 'Guardando...' : 'Guardar local'),
          ),
        ],
      ),
    );
  }

  Widget _field(
    String label,
    TextEditingController controller, {
    bool required = true,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: FudiSpacing.md),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(labelText: label),
        validator: required
            ? (value) => value == null || value.trim().isEmpty
                  ? 'Campo requerido'
                  : null
            : null,
      ),
    );
  }

  Future<void> _save(BusinessLocation? existing) async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final business = await ref.read(currentBusinessProvider.future);
      if (business == null) return;
      final saved = await ref
          .read(businessLocationRepositoryProvider)
          .upsertLocation(
            BusinessLocation(
              id: existing?.id ?? '',
              businessId: business.id,
              name: _name.text.trim(),
              address: _address.text.trim(),
              phone: _phone.text.trim().isEmpty ? null : _phone.text.trim(),
              latitude: existing?.latitude,
              longitude: existing?.longitude,
              isActive: _isActive,
            ),
          );
      ref.invalidate(businessLocationsProvider(business.id));
      ref.invalidate(businessLocationProvider(saved.id));
      if (mounted) context.pop();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
