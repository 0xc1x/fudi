import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart' as geo;
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/error/user_friendly_message.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/ui/fudi_colors.dart';
import '../../../../core/ui/fudi_icons.dart';
import '../../../../core/ui/fudi_spacing.dart';
import '../../../../core/ui/fudi_typography.dart';
import '../../domain/business_profile.dart';
import '../../../auth/presentation/auth_state_provider.dart';
import '../business_providers.dart';
import '../business_profile_providers.dart';
import 'map_picker_screen.dart';

class BusinessLocationCreateScreen extends ConsumerStatefulWidget {
  const BusinessLocationCreateScreen({super.key});

  @override
  ConsumerState<BusinessLocationCreateScreen> createState() => _BusinessLocationCreateScreenState();
}

class _BusinessLocationCreateScreenState extends ConsumerState<BusinessLocationCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _websiteController = TextEditingController();
  
  LatLng? _selectedLocation;
  XFile? _logoFile;
  XFile? _coverFile;
  String _selectedType = 'Bakery';
  
  final Map<String, BusinessHoursState> _hoursState = {
    'Lunes': BusinessHoursState(open: const TimeOfDay(hour: 6, minute: 0), close: const TimeOfDay(hour: 20, minute: 0)),
    'Martes': BusinessHoursState(open: const TimeOfDay(hour: 6, minute: 0), close: const TimeOfDay(hour: 20, minute: 0)),
    'Miércoles': BusinessHoursState(open: const TimeOfDay(hour: 6, minute: 0), close: const TimeOfDay(hour: 20, minute: 0)),
    'Jueves': BusinessHoursState(open: const TimeOfDay(hour: 6, minute: 0), close: const TimeOfDay(hour: 20, minute: 0)),
    'Viernes': BusinessHoursState(open: const TimeOfDay(hour: 6, minute: 0), close: const TimeOfDay(hour: 20, minute: 0)),
    'Sábado': BusinessHoursState(open: const TimeOfDay(hour: 7, minute: 0), close: const TimeOfDay(hour: 19, minute: 0)),
    'Domingo': BusinessHoursState(open: const TimeOfDay(hour: 8, minute: 0), close: const TimeOfDay(hour: 14, minute: 0)),
  };

  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _descriptionController.dispose();
    _websiteController.dispose();
    super.dispose();
  }

  void _copyMondayToAll() {
    final monday = _hoursState['Lunes']!;
    setState(() {
      for (var day in _hoursState.keys) {
        _hoursState[day] = BusinessHoursState(open: monday.open, close: monday.close, isClosed: monday.isClosed);
      }
    });
  }

  Future<void> _selectTime(String day, bool isOpen) async {
    final state = _hoursState[day]!;
    final initialTime = isOpen ? state.open : state.close;
    
    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: FudiColors.primary),
        ),
        child: child!,
      ),
    );

    if (picked != null) {
      setState(() {
        if (isOpen) {
          _hoursState[day] = state.copyWith(open: picked);
        } else {
          _hoursState[day] = state.copyWith(close: picked);
        }
      });
    }
  }

  Future<void> _pickImage(bool isLogo) async {
    final ImagePicker picker = ImagePicker();
    
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(isLogo ? 'Logo del negocio' : 'Imagen de portada', style: FudiTypography.h4),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _SourceOption(
                    icon: Icons.camera_alt_outlined,
                    label: 'Cámara',
                    onTap: () => Navigator.pop(context, ImageSource.camera),
                  ),
                  _SourceOption(
                    icon: Icons.photo_library_outlined,
                    label: 'Galería',
                    onTap: () => Navigator.pop(context, ImageSource.gallery),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );

    if (source != null) {
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      
        if (image != null) {
          setState(() {
            if (isLogo) {
              _logoFile = image;
            } else {
              _coverFile = image;
            }
          });
        }
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final authState = ref.read(authSessionNotifierProvider);
      final userId = authState.session?.user.id;
      if (userId == null) throw Exception('Sesión no encontrada');

      final repo = ref.read(businessProfileRepositoryProvider);
      
      final businessProfile = BusinessProfile(
        id: '',
        name: _nameController.text,
        type: _selectedType,
        address: _addressController.text,
        rating: 0.0,
        phone: _phoneController.text,
        email: _emailController.text,
        website: _websiteController.text.isNotEmpty ? _websiteController.text : null,
        description: _descriptionController.text.isNotEmpty ? _descriptionController.text : null,
        latitude: _selectedLocation?.latitude,
        longitude: _selectedLocation?.longitude,
        imageUrl: _logoFile?.path,
        coverImageUrl: _coverFile?.path,
        hours: _hoursState.entries.map((e) {
          final open = '${e.value.open.hour.toString().padLeft(2, '0')}:${e.value.open.minute.toString().padLeft(2, '0')}';
          final close = '${e.value.close.hour.toString().padLeft(2, '0')}:${e.value.close.minute.toString().padLeft(2, '0')}';
          return BusinessHours(
            day: e.key,
            hours: e.value.isClosed ? 'Cerrado' : '$open - $close',
          );
        }).toList(),
      );

      await repo.createBusiness(businessProfile, userId, logoFile: _logoFile, coverFile: _coverFile);
      
        if (mounted) {
          ref.invalidate(userBusinessesProvider);
          ref.invalidate(currentBusinessProvider);
          context.pushReplacementNamed(RouteNames.businessProductCreate);
        }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(userFriendlyMessage(e)),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FudiColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(FudiIcons.chevronLeft),
          onPressed: () => context.pop(),
        ),
        title: const Text('Nuevo local', style: FudiTypography.h4),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(FudiSpacing.md),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildImagesSection(),
              const SizedBox(height: FudiSpacing.lg),
              _buildBasicInfoSection(),
              const SizedBox(height: FudiSpacing.lg),
              _buildHoursSection(),
              const SizedBox(height: 100), 
            ],
          ),
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(FudiSpacing.md),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: FudiColors.border)),
        ),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isSubmitting ? null : _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: FudiColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: _isSubmitting
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('Crear local', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ),
      ),
    );
  }

  Widget _buildImagesSection() {
    return Container(
      padding: const EdgeInsets.all(FudiSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: FudiColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Imágenes del negocio', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          // Cover Image
          const Text('Imagen de portada', style: TextStyle(fontSize: 12, color: FudiColors.mutedForeground)),
          const SizedBox(height: 8),
          InkWell(
            onTap: () => _pickImage(false),
            child: Container(
              width: double.infinity,
              height: 120,
              decoration: BoxDecoration(
                color: FudiColors.background,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: FudiColors.border),
              ),
        child: _coverFile != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: kIsWeb
                    ? Image.network(_coverFile!.path, fit: BoxFit.cover)
                    : Image.network(_coverFile!.path, fit: BoxFit.cover),
              )
            : const Center(child: Icon(Icons.add_photo_alternate_outlined, color: FudiColors.mutedForeground)),
            ),
          ),
          const SizedBox(height: 16),
          // Logo
          const Text('Logo del negocio', style: TextStyle(fontSize: 12, color: FudiColors.mutedForeground)),
          const SizedBox(height: 8),
          InkWell(
            onTap: () => _pickImage(true),
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: FudiColors.background,
                shape: BoxShape.circle,
                border: Border.all(color: FudiColors.border),
              ),
        child: _logoFile != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(40),
                child: kIsWeb
                    ? Image.network(_logoFile!.path, fit: BoxFit.cover)
                    : Image.network(_logoFile!.path, fit: BoxFit.cover),
              )
            : const Center(child: Icon(Icons.camera_alt_outlined, color: FudiColors.mutedForeground)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return Container(
      padding: const EdgeInsets.all(FudiSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: FudiColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Información del local', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildField(label: 'Nombre del local *', controller: _nameController, hint: 'Ej: Panadería El Centro'),
          const SizedBox(height: 16),
          _buildDropdownField(
            label: 'Tipo de negocio *',
            options: {
              'Bakery': 'Panadería',
              'Restaurant': 'Restaurante',
              'Cafe': 'Cafetería',
              'Grocery': 'Supermercado',
              'Other': 'Otro'
            },
            value: _selectedType,
            onChanged: (val) => setState(() => _selectedType = val!),
          ),
          const SizedBox(height: 16),
          _buildField(
            label: 'Dirección *',
            controller: _addressController,
            hint: 'Selecciona en el mapa',
            icon: FudiIcons.mapPin,
            suffix: TextButton(
              onPressed: () async {
                final LatLng? result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MapPickerScreen(initialLocation: _selectedLocation)),
                );
                if (result != null) {
                  setState(() => _selectedLocation = result);
                  try {
                    final placemarks = await geo.placemarkFromCoordinates(result.latitude, result.longitude);
                    if (placemarks.isNotEmpty) {
                      final p = placemarks.first;
                      _addressController.text = [p.street, p.subLocality, p.locality].where((s) => s != null && s.isNotEmpty).join(', ');
                    }
                  } catch (_) {}
                  setState(() {});
                }
              },
              child: const Text('Pin en mapa', style: TextStyle(fontSize: 12)),
            ),
          ),
          const SizedBox(height: 16),
          _buildField(label: 'Descripción', controller: _descriptionController, hint: 'Breve descripción de tu local', maxLines: 3),
          const SizedBox(height: 16),
          _buildField(label: 'Teléfono *', controller: _phoneController, hint: 'Ej: 0987654321', icon: FudiIcons.phone, keyboardType: TextInputType.phone),
          const SizedBox(height: 16),
          _buildField(label: 'Email *', controller: _emailController, hint: 'contacto@negocio.com', icon: FudiIcons.mail, keyboardType: TextInputType.emailAddress),
          const SizedBox(height: 16),
          _buildField(label: 'Sitio Web (Opcional)', controller: _websiteController, hint: 'www.tu-negocio.com', icon: Icons.language),
        ],
      ),
    );
  }

  Widget _buildField({required String label, required TextEditingController controller, required String hint, IconData? icon, TextInputType? keyboardType, Widget? suffix, int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(children: [
              if (icon != null) ...[Icon(icon, size: 16, color: FudiColors.mutedForeground), const SizedBox(width: 8)],
              Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            ]),
            suffix ?? const SizedBox.shrink(),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: FudiColors.background.withValues(alpha: 0.5),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          validator: (value) => (value == null || value.isEmpty) && label.contains('*') ? 'Campo requerido' : null,
        ),
      ],
    );
  }

  Widget _buildDropdownField({required String label, required Map<String, String> options, required String value, required Function(String?) onChanged}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(color: FudiColors.background.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(12)),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              items: options.entries.map((e) => DropdownMenuItem(value: e.key, child: Text(e.value))).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHoursSection() {
    return Container(
      padding: const EdgeInsets.all(FudiSpacing.md),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: FudiColors.border)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(children: [Icon(FudiIcons.clock, size: 20), SizedBox(width: 8), Text('Horario de atención', style: TextStyle(fontWeight: FontWeight.bold))]),
              TextButton(onPressed: _copyMondayToAll, child: const Text('Copiar lunes', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
            ],
          ),
          const SizedBox(height: 8),
          ..._hoursState.entries.map((e) => _buildDayRow(e.key, e.value)),
        ],
      ),
    );
  }

  Widget _buildDayRow(String day, BusinessHoursState state) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          SizedBox(width: 85, child: Text(day, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500))),
          Expanded(child: Row(children: [
            _buildTimeButton(day, state.open, true),
            const Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text('-', style: TextStyle(color: FudiColors.mutedForeground))),
            _buildTimeButton(day, state.close, false),
          ])),
          const SizedBox(width: 8),
          _buildClosedToggle(day, state.isClosed),
        ],
      ),
    );
  }

  Widget _buildTimeButton(String day, TimeOfDay time, bool isOpen) {
    final isClosed = _hoursState[day]!.isClosed;
    return Expanded(
      child: InkWell(
        onTap: isClosed ? null : () => _selectTime(day, isOpen),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(color: isClosed ? FudiColors.background : Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: FudiColors.border)),
          child: Text(time.format(context), textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: isClosed ? FudiColors.mutedForeground : Colors.black)),
        ),
      ),
    );
  }

  Widget _buildClosedToggle(String day, bool isClosed) {
    return InkWell(
      onTap: () => setState(() => _hoursState[day] = _hoursState[day]!.copyWith(isClosed: !isClosed)),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isClosed ? FudiColors.primary.withValues(alpha: 0.1) : FudiColors.background,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: isClosed ? FudiColors.primary : FudiColors.border),
        ),
        child: Text(isClosed ? 'Cerrado' : 'Abierto', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isClosed ? FudiColors.primary : FudiColors.mutedForeground)),
      ),
    );
  }
}

class _SourceOption extends StatelessWidget {
  const _SourceOption({required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(width: 100, padding: const EdgeInsets.symmetric(vertical: 16), child: Column(children: [Icon(icon, size: 32, color: FudiColors.primary), const SizedBox(height: 8), Text(label, style: const TextStyle(fontWeight: FontWeight.w500))])),
    );
  }
}

class BusinessHoursState {
  final TimeOfDay open;
  final TimeOfDay close;
  final bool isClosed;
  BusinessHoursState({required this.open, required this.close, this.isClosed = false});
  BusinessHoursState copyWith({TimeOfDay? open, TimeOfDay? close, bool? isClosed}) {
    return BusinessHoursState(open: open ?? this.open, close: close ?? this.close, isClosed: isClosed ?? this.isClosed);
  }
}
