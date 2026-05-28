import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/error/user_friendly_message.dart';
import '../../../../core/ui/fudi_colors.dart';
import '../../../../core/ui/atoms/icons/fudi_icons.dart';
import '../../../../core/ui/fudi_spacing.dart';
import '../../../../core/ui/fudi_typography.dart';
import '../../../offers/domain/offer.dart';
import '../../../offers/presentation/offer_providers.dart';
import '../business_providers.dart';
import '../business_profile_providers.dart';
import '../../../auth/presentation/auth_state_provider.dart';

class BusinessProductFormScreen extends ConsumerStatefulWidget {
  const BusinessProductFormScreen({super.key, this.productId});

  final String? productId;

  @override
  ConsumerState<BusinessProductFormScreen> createState() =>
      _BusinessProductFormScreenState();
}

class _BusinessProductFormScreenState
    extends ConsumerState<BusinessProductFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _originalPriceController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  final _includesController = TextEditingController();
  final _allergensController = TextEditingController();

  String _selectedCategory = 'Sorpresa';
  XFile? _imageFile;
  TimeOfDay _startTime = const TimeOfDay(hour: 18, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 20, minute: 0);

  bool _isSubmitting = false;

  String? _existingImageUrl;
  bool _isLoadingProduct = false;

  final List<String> _categories = [
    'Sorpresa',
    'Panadería',
    'Comida Preparada',
    'Frutas y Verduras',
    'Lácteos',
    'Carnes',
    'Snacks',
    'Otro',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.productId != null) {
      _loadProduct();
    }
  }

  Future<void> _loadProduct() async {
    setState(() => _isLoadingProduct = true);
    try {
      final offer = await ref.read(
        offerDetailProvider(widget.productId!).future,
      );
      if (mounted) {
        _nameController.text = offer.title;
        _descriptionController.text = offer.description ?? '';
        _originalPriceController.text = offer.originalPrice.toStringAsFixed(2);
        _priceController.text = offer.discountedPrice.toStringAsFixed(2);
        _stockController.text = offer.stock.toString();
        _includesController.text = offer.includes ?? '';
        _allergensController.text = offer.allergens ?? '';
        _selectedCategory = offer.category ?? 'Sorpresa';
        _startTime = TimeOfDay(
          hour: offer.pickupStart.hour,
          minute: offer.pickupStart.minute,
        );
        _endTime = TimeOfDay(
          hour: offer.pickupEnd.hour,
          minute: offer.pickupEnd.minute,
        );
        _existingImageUrl = offer.imageUrl;
        setState(() {});
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error al cargar producto: ${userFriendlyMessage(e)}',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoadingProduct = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _originalPriceController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _includesController.dispose();
    _allergensController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
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
              const Text('Imagen del producto', style: FudiTypography.h4),
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
        setState(() => _imageFile = image);
      }
    }
  }

  Future<void> _selectTime(bool isStart) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _startTime : _endTime,
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final authState = ref.read(authSessionNotifierProvider);
      final userId = authState.session?.user.id;
      if (userId == null) throw Exception('Sesión no encontrada');

      var business = await ref.read(currentBusinessProvider.future);

      if (business == null) {
        ref.invalidate(userBusinessesProvider);
        ref.invalidate(currentBusinessProvider);

        final profileRepo = ref.read(businessProfileRepositoryProvider);
        final businesses = await profileRepo.getBusinessesByOwnerId(userId);
        if (businesses.isEmpty) {
          throw Exception(
            'No se encontró un local registrado. Por favor crea uno primero.',
          );
        }
        business = businesses.first;
      }

      final repo = ref.read(businessCatalogRepositoryProvider);

      final offer = Offer(
        id: widget.productId ?? '',
        businessId: business.id,
        business: BusinessInfo(
          id: business.id,
          name: business.name,
          type: business.type,
          rating: business.rating,
          address: business.address,
          imageUrl: business.imageUrl,
          latitude: business.latitude,
          longitude: business.longitude,
        ),
        title: _nameController.text,
        description: _descriptionController.text,
        imageUrl: _imageFile?.path ?? _existingImageUrl ?? '',
        originalPrice: double.parse(_originalPriceController.text),
        discountedPrice: double.parse(_priceController.text),
        stock: int.parse(_stockController.text),
        initialStock: int.parse(_stockController.text),
        category: _selectedCategory,
        pickupStart: DateTime(2024, 1, 1, _startTime.hour, _startTime.minute),
        pickupEnd: DateTime(2024, 1, 1, _endTime.hour, _endTime.minute),
        isActive: true,
        rating: 0.0,
        includes: _includesController.text.isNotEmpty
            ? _includesController.text
            : null,
        allergens: _allergensController.text.isNotEmpty
            ? _allergensController.text
            : null,
      );

      if (widget.productId == null) {
        await repo.createOffer(offer, imageFile: _imageFile);
      } else {
        await repo.updateOffer(offer, imageFile: _imageFile);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Producto guardado correctamente')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(userFriendlyMessage(e)),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingProduct) {
      return Scaffold(
        backgroundColor: FudiColors.background,
        appBar: AppBar(
          title: const Text('Editar producto'),
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: FudiColors.background,
      appBar: AppBar(
        title: Text(
          widget.productId == null ? 'Nuevo producto' : 'Editar producto',
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(FudiSpacing.md),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildImagePicker(),
              const SizedBox(height: FudiSpacing.lg),
              _buildSection(
                title: 'Información básica',
                children: [
                  _buildTextField(
                    label: 'Nombre del producto',
                    controller: _nameController,
                    hint: 'Ej: Pack Sorpresa Panadería',
                    validator: (v) =>
                        v?.isEmpty ?? true ? 'Campo requerido' : null,
                  ),
                  const SizedBox(height: FudiSpacing.md),
                  _buildDropdownField(
                    label: 'Categoría',
                    value: _selectedCategory,
                    items: _categories,
                    onChanged: (v) => setState(() => _selectedCategory = v!),
                  ),
                  const SizedBox(height: FudiSpacing.md),
                  _buildTextField(
                    label: 'Descripción',
                    controller: _descriptionController,
                    hint: 'Describe brevemente qué trae el producto...',
                    maxLines: 3,
                    validator: (v) =>
                        v?.isEmpty ?? true ? 'Campo requerido' : null,
                  ),
                ],
              ),
              const SizedBox(height: FudiSpacing.lg),
              _buildSection(
                title: 'Detalles adicionales (Mockup)',
                children: [
                  _buildTextField(
                    label: '¿Qué incluye?',
                    controller: _includesController,
                    hint: 'Ej: 3 panes, 2 facturas...',
                    maxLines: 2,
                  ),
                  const SizedBox(height: FudiSpacing.md),
                  _buildTextField(
                    label: 'Alérgenos',
                    controller: _allergensController,
                    hint: 'Ej: Gluten, Lactosa...',
                  ),
                ],
              ),
              const SizedBox(height: FudiSpacing.lg),
              _buildSection(
                title: 'Precios y Stock',
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          label: 'Precio Original',
                          controller: _originalPriceController,
                          hint: '0.00',
                          keyboardType: TextInputType.number,
                          prefixText: '\$ ',
                          validator: (v) =>
                              v?.isEmpty ?? true ? 'Requerido' : null,
                        ),
                      ),
                      const SizedBox(width: FudiSpacing.md),
                      Expanded(
                        child: _buildTextField(
                          label: 'Precio Fudi',
                          controller: _priceController,
                          hint: '0.00',
                          keyboardType: TextInputType.number,
                          prefixText: '\$ ',
                          validator: (v) =>
                              v?.isEmpty ?? true ? 'Requerido' : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: FudiSpacing.md),
                  _buildTextField(
                    label: 'Stock disponible',
                    controller: _stockController,
                    hint: '1',
                    keyboardType: TextInputType.number,
                    validator: (v) => v?.isEmpty ?? true ? 'Requerido' : null,
                  ),
                ],
              ),
              const SizedBox(height: FudiSpacing.lg),
              _buildSection(
                title: 'Horario de recogida',
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildTimePicker(
                          label: 'Desde',
                          time: _startTime,
                          onTap: () => _selectTime(true),
                        ),
                      ),
                      const SizedBox(width: FudiSpacing.md),
                      Expanded(
                        child: _buildTimePicker(
                          label: 'Hasta',
                          time: _endTime,
                          onTap: () => _selectTime(false),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: FudiSpacing.xxl),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _isSubmitting ? null : _submit,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isSubmitting
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Guardar producto'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    final hasNewImage = _imageFile != null;
    final hasExistingImage =
        _existingImageUrl != null && _existingImageUrl!.isNotEmpty;
    final showImage = hasNewImage || hasExistingImage;

    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        height: 180,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(FudiRadius.xl),
          border: Border.all(color: FudiColors.borderSolid),
        ),
        child: showImage
            ? ClipRRect(
                borderRadius: BorderRadius.circular(FudiRadius.xl),
                child: hasNewImage
                    ? Image.network(_imageFile!.path, fit: BoxFit.cover)
                    : Image.network(_existingImageUrl!, fit: BoxFit.cover),
              )
            : const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.camera_alt_rounded,
                    size: 48,
                    color: FudiColors.mutedForeground,
                  ),
                  SizedBox(height: FudiSpacing.sm),
                  Text(
                    'Subir foto del producto',
                    style: FudiTypography.labelSmall,
                  ),
                  Text('Opcional', style: FudiTypography.bodySmall),
                ],
              ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: FudiTypography.h2),
        const SizedBox(height: FudiSpacing.md),
        Container(
          padding: const EdgeInsets.all(FudiSpacing.md),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(FudiRadius.xl),
            border: Border.all(color: FudiColors.borderSolid),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? prefixText,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: FudiTypography.labelSmall),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            prefixText: prefixText,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(FudiRadius.lg),
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: FudiTypography.labelSmall),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: value,
          items: items
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(FudiRadius.lg),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimePicker({
    required String label,
    required TimeOfDay time,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: FudiTypography.labelSmall),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: FudiColors.borderSolid),
              borderRadius: BorderRadius.circular(FudiRadius.lg),
            ),
            child: Row(
              children: [
                const Icon(FudiIcons.clock, size: 20),
                const SizedBox(width: 8),
                Text(time.format(context)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SourceOption extends StatelessWidget {
  const _SourceOption({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 100,
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: FudiColors.primary),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}
