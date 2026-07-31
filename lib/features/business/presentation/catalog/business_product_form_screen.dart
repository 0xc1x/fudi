import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/error/user_friendly_message.dart';
import '../../../../core/ui/atoms/fudi_date_picker_tile.dart';
import '../../../../core/ui/atoms/fudi_discount_meta_badge.dart';
import '../../../../core/ui/atoms/fudi_dropdown_form_field.dart';
import '../../../../core/ui/atoms/fudi_text_form_field.dart';
import '../../../../core/ui/atoms/fudi_time_picker_tile.dart';
import '../../../../core/ui/fudi_colors.dart';
import '../../../../core/ui/fudi_form_section.dart';
import '../../../../core/ui/fudi_form_submit_bar.dart';
import '../../../../core/ui/fudi_image_picker_field.dart';
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

  final _nameFocus = FocusNode();
  final _descriptionFocus = FocusNode();
  final _includesFocus = FocusNode();
  final _allergensFocus = FocusNode();
  final _originalPriceFocus = FocusNode();
  final _priceFocus = FocusNode();
  final _stockFocus = FocusNode();

  final Set<String> _selectedCategoryIds = <String>{};
  XFile? _imageFile;
  DateTime _startDate = DateTime.now();
  TimeOfDay _startTime = const TimeOfDay(hour: 18, minute: 0);
  DateTime _endDate = DateTime.now();
  TimeOfDay _endTime = const TimeOfDay(hour: 20, minute: 0);

  bool _isSubmitting = false;
  bool _autoValidate = false;
  bool _isDirty = false;

  String? _existingImageUrl;
  bool _isLoadingProduct = false;
  String? _selectedLocationId;

  @override
  void initState() {
    super.initState();
    if (widget.productId != null) {
      unawaited(_loadProduct());
    }
    for (final controller in [
      _nameController,
      _descriptionController,
      _originalPriceController,
      _priceController,
      _stockController,
      _includesController,
      _allergensController,
    ]) {
      controller.addListener(_markDirty);
    }
  }

  void _markDirty() {
    if (!_isDirty) {
      setState(() => _isDirty = true);
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
        _selectedCategoryIds
          ..clear()
          ..addAll(offer.categories.map((c) => c.id));
        _startDate = DateTime(
          offer.pickupStart.year,
          offer.pickupStart.month,
          offer.pickupStart.day,
        );
        _startTime = TimeOfDay(
          hour: offer.pickupStart.hour,
          minute: offer.pickupStart.minute,
        );
        _endDate = DateTime(
          offer.pickupEnd.year,
          offer.pickupEnd.month,
          offer.pickupEnd.day,
        );
        _endTime = TimeOfDay(
          hour: offer.pickupEnd.hour,
          minute: offer.pickupEnd.minute,
        );
        _existingImageUrl = offer.imageUrl;
        _selectedLocationId =
            offer.businessLocationId.isNotEmpty ? offer.businessLocationId : null;
        setState(() {});
        _isDirty = false;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error al cargar producto: ${userFriendlyMessage(e)}',
            ),
            backgroundColor: FudiColors.destructive,
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
    _nameFocus.dispose();
    _descriptionFocus.dispose();
    _includesFocus.dispose();
    _allergensFocus.dispose();
    _originalPriceFocus.dispose();
    _priceFocus.dispose();
    _stockFocus.dispose();
    super.dispose();
  }

  void _onImageChanged(XFile? file, String? existingUrl) {
    setState(() {
      _imageFile = file;
      _existingImageUrl = existingUrl;
      _isDirty = true;
    });
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
        _isDirty = true;
      });
    }
  }

  Future<void> _selectDate(bool isStart) async {
    final now = DateTime.now();
    final initial = isStart ? _startDate : _endDate;

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: initial.isBefore(now) ? initial : now,
      lastDate: now.add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          if (_endDate.isBefore(_startDate)) {
            _endDate = _startDate;
          }
        } else {
          _endDate = picked;
        }
        _isDirty = true;
      });
    }
  }

  DateTime get _pickupStartAt => DateTime(
    _startDate.year,
    _startDate.month,
    _startDate.day,
    _startTime.hour,
    _startTime.minute,
  );

  DateTime get _pickupEndAt => DateTime(
    _endDate.year,
    _endDate.month,
    _endDate.day,
    _endTime.hour,
    _endTime.minute,
  );

  bool get _hasValidPickupWindow => _pickupEndAt.isAfter(_pickupStartAt);

  double? get _originalPriceValue =>
      double.tryParse(_originalPriceController.text.replaceAll(',', '.'));

  double? get _discountedPriceValue =>
      double.tryParse(_priceController.text.replaceAll(',', '.'));

  double? get _discountPercent {
    final original = _originalPriceValue;
    final discounted = _discountedPriceValue;
    if (original == null || discounted == null || original <= 0) return null;
    if (discounted >= original) return null;
    return ((original - discounted) / original) * 100;
  }

  Future<bool> _confirmDiscardChanges() async {
    if (!_isDirty) return true;
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Descartar cambios?'),
        content: const Text(
          'Tienes cambios sin guardar. Si sales ahora, se perderán.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Seguir editando'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Descartar'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Future<void> _submit() async {
    setState(() => _autoValidate = true);

    if (!_formKey.currentState!.validate()) return;

    if (!_hasValidPickupWindow) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'La hora/fecha de fin debe ser posterior a la de inicio.',
          ),
          backgroundColor: FudiColors.destructive,
        ),
      );
      return;
    }

    if (_selectedCategoryIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecciona al menos una categoría.'),
          backgroundColor: FudiColors.destructive,
        ),
      );
      return;
    }

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

      final allCategories = await ref.read(categoriesProvider.future);
      final selectedCategories = allCategories
          .where((c) => _selectedCategoryIds.contains(c.id))
          .toList();

      final effectiveLocationId =
          _selectedLocationId ?? business.businessLocationId;

      final offer = Offer(
        id: widget.productId ?? '',
        businessId: business.id,
        businessLocationId: effectiveLocationId ?? '',
        business: BusinessInfo(
          id: business.id,
          name: business.name,
          type: business.type,
          rating: business.rating,
          address: business.address ?? '',
          imageUrl: business.imageUrl,
          latitude: business.latitude,
          longitude: business.longitude,
          zone: business.zone,
        ),
        title: _nameController.text,
        description: _descriptionController.text,
        imageUrl: _imageFile?.path ?? _existingImageUrl ?? '',
        originalPrice: double.parse(_originalPriceController.text),
        discountedPrice: double.parse(_priceController.text),
        stock: int.parse(_stockController.text),
        initialStock: int.parse(_stockController.text),
        categories: selectedCategories,
        pickupStart: _pickupStartAt,
        pickupEnd: _pickupEndAt,
        isActive: true,
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
        ref.invalidate(businessOffersProvider(business.id));
        _isDirty = false;
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
            backgroundColor: FudiColors.destructive,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    if (_isLoadingProduct) {
      return Scaffold(
        backgroundColor: colorScheme.surface,
        appBar: AppBar(
          title: const Text('Editar producto'),
          backgroundColor: Theme.of(context).colorScheme.surface,
          elevation: 0,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return PopScope(
      canPop: !_isDirty,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await _confirmDiscardChanges();
        if (shouldPop && context.mounted) {
          context.pop();
        }
      },
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        appBar: AppBar(
          title: Text(
            widget.productId == null ? 'Nuevo producto' : 'Editar producto',
          ),
          backgroundColor: Theme.of(context).colorScheme.surface,
          elevation: 0,
        ),
        body: AbsorbPointer(
          absorbing: _isSubmitting,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              FudiSpacing.md,
              FudiSpacing.md,
              FudiSpacing.md,
              FudiSpacing.xxl,
            ),
            child: Form(
              key: _formKey,
              autovalidateMode: _autoValidate
                  ? AutovalidateMode.onUserInteraction
                  : AutovalidateMode.disabled,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FudiImagePickerField(
                    existingImageUrl: _existingImageUrl,
                    onChanged: _onImageChanged,
                  ),
                  const SizedBox(height: FudiSpacing.lg),
                  FudiFormSection(
                    title: 'Información básica',
                    icon: Icons.info_outline_rounded,
                    children: [
                      FudiTextFormField(
                        label: 'Nombre del producto',
                        controller: _nameController,
                        hint: 'Ej: Pack Sorpresa Panadería',
                        focusNode: _nameFocus,
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) =>
                            _descriptionFocus.requestFocus(),
                        validator: (v) => v?.trim().isEmpty ?? true
                            ? 'Campo requerido'
                            : null,
                      ),
                      const SizedBox(height: FudiSpacing.md),
                      _buildCategorySelector(),
                      const SizedBox(height: FudiSpacing.md),
                      _buildLocationSelector(),
                      const SizedBox(height: FudiSpacing.md),
                      FudiTextFormField(
                        label: 'Descripción',
                        controller: _descriptionController,
                        hint: 'Describe brevemente qué trae el producto...',
                        maxLines: 3,
                        focusNode: _descriptionFocus,
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) => _includesFocus.requestFocus(),
                        validator: (v) => v?.trim().isEmpty ?? true
                            ? 'Campo requerido'
                            : null,
                      ),
                    ],
                  ),
                  const SizedBox(height: FudiSpacing.lg),
                  FudiFormSection(
                    title: 'Detalles adicionales',
                    icon: Icons.checklist_rounded,
                    badge: 'Opcional',
                    children: [
                      FudiTextFormField(
                        label: '¿Qué incluye?',
                        controller: _includesController,
                        hint: 'Ej: 3 panes, 2 facturas...',
                        maxLines: 2,
                        focusNode: _includesFocus,
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) =>
                            _allergensFocus.requestFocus(),
                      ),
                      const SizedBox(height: FudiSpacing.md),
                      FudiTextFormField(
                        label: 'Alérgenos',
                        controller: _allergensController,
                        hint: 'Ej: Gluten, Lactosa...',
                        focusNode: _allergensFocus,
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) =>
                            _originalPriceFocus.requestFocus(),
                      ),
                    ],
                  ),
                  const SizedBox(height: FudiSpacing.lg),
                  FudiFormSection(
                    title: 'Precios y stock',
                    icon: Icons.sell_outlined,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: FudiTextFormField(
                              label: 'Precio original',
                              controller: _originalPriceController,
                              hint: '0.00',
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              prefixText: '\$ ',
                              focusNode: _originalPriceFocus,
                              textInputAction: TextInputAction.next,
                              onFieldSubmitted: (_) =>
                                  _priceFocus.requestFocus(),
                              validator: _validatePositivePrice,
                            ),
                          ),
                          const SizedBox(width: FudiSpacing.md),
                          Expanded(
                            child: FudiTextFormField(
                              label: 'Precio Fudi',
                              controller: _priceController,
                              hint: '0.00',
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              prefixText: '\$ ',
                              focusNode: _priceFocus,
                              textInputAction: TextInputAction.next,
                              onFieldSubmitted: (_) =>
                                  _stockFocus.requestFocus(),
                              validator: _validateDiscountedPrice,
                            ),
                          ),
                        ],
                      ),
                      if (_discountPercent != null) ...[
                        const SizedBox(height: FudiSpacing.sm),
                        FudiDiscountMetaBadge(percent: _discountPercent!),
                      ],
                      const SizedBox(height: FudiSpacing.md),
                      FudiTextFormField(
                        label: 'Stock disponible',
                        controller: _stockController,
                        hint: '1',
                        keyboardType: TextInputType.number,
                        focusNode: _stockFocus,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _stockFocus.unfocus(),
                        validator: (v) {
                          final n = int.tryParse(v?.trim() ?? '');
                          if (n == null) return 'Requerido';
                          if (n < 1) return 'Debe ser al menos 1';
                          return null;
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: FudiSpacing.lg),
                  FudiFormSection(
                    title: 'Horario de recogida',
                    icon: Icons.schedule_rounded,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: FudiDatePickerTile(
                              label: 'Fecha desde',
                              date: _startDate,
                              onTap: () => _selectDate(true),
                            ),
                          ),
                          const SizedBox(width: FudiSpacing.md),
                          Expanded(
                            child: FudiDatePickerTile(
                              label: 'Fecha hasta',
                              date: _endDate,
                              onTap: () => _selectDate(false),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: FudiSpacing.md),
                      Row(
                        children: [
                          Expanded(
                            child: FudiTimePickerTile(
                              label: 'Hora desde',
                              time: _startTime,
                              onTap: () => _selectTime(true),
                            ),
                          ),
                          const SizedBox(width: FudiSpacing.md),
                          Expanded(
                            child: FudiTimePickerTile(
                              label: 'Hora hasta',
                              time: _endTime,
                              onTap: () => _selectTime(false),
                            ),
                          ),
                        ],
                      ),
                      if (!_hasValidPickupWindow) ...[
                        const SizedBox(height: FudiSpacing.sm),
                        Row(
                          children: [
                            const Icon(
                              Icons.error_outline_rounded,
                              size: 16,
                              color: FudiColors.destructive,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'La fecha/hora de fin debe ser posterior a la de inicio.',
                                style: FudiTypography.bodySmall.copyWith(
                                  color: FudiColors.destructive,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: FudiFormSubmitBar(
          text: widget.productId == null
              ? 'Publicar producto'
              : 'Guardar cambios',
          onPressed: _isSubmitting ? null : _submit,
          isLoading: _isSubmitting,
        ),
      ),
    );
  }

  Widget _buildCategorySelector() {
    final categoriesAsync = ref.watch(categoriesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Categorías', style: FudiTypography.labelMedium),
        const SizedBox(height: FudiSpacing.sm),
        categoriesAsync.when(
          data: (categories) {
            if (categories.isEmpty) {
              return Text(
                'No hay categorías disponibles',
                style: FudiTypography.bodySmall.copyWith(
                  color: FudiColors.mutedForeground,
                ),
              );
            }
            return Wrap(
              spacing: FudiSpacing.sm,
              runSpacing: FudiSpacing.sm,
              children: categories.map((cat) {
                final selected = _selectedCategoryIds.contains(cat.id);
                final label = (cat.emoji != null && cat.emoji!.isNotEmpty)
                    ? '${cat.emoji} ${cat.name}'
                    : cat.name;
                return FilterChip(
                  label: Text(label),
                  selected: selected,
                  onSelected: (value) {
                    setState(() {
                      if (value) {
                        _selectedCategoryIds.add(cat.id);
                      } else {
                        _selectedCategoryIds.remove(cat.id);
                      }
                      _isDirty = true;
                    });
                  },
                );
              }).toList(),
            );
          },
          loading: () => const SizedBox(
            height: 32,
            child: Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
          error: (_, _) => Text(
            'No se pudieron cargar las categorías.',
            style: FudiTypography.bodySmall.copyWith(
              color: FudiColors.destructive,
            ),
          ),
        ),
        if (_autoValidate && _selectedCategoryIds.isEmpty) ...[
          const SizedBox(height: FudiSpacing.xs),
          Text(
            'Selecciona al menos una categoría.',
            style: FudiTypography.bodySmall.copyWith(
              color: FudiColors.destructive,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildLocationSelector() {
    return Consumer(
      builder: (context, ref, _) {
        final businessAsync = ref.watch(currentBusinessProvider);
        final business = businessAsync.asData?.value;
        if (business == null) return const SizedBox.shrink();

        final locationsAsync = ref.watch(businessLocationsProvider(business.id));
        final locations = locationsAsync.asData?.value ?? [];

        final currentValue = _selectedLocationId ?? '';

        return FudiDropdownFormField<String>(
          label: 'Sucursal',
          value: currentValue,
          items: [
            const DropdownMenuItem<String>(
              value: '',
              child: Text('Sin sucursal (todas)'),
            ),
            for (final loc in locations)
              DropdownMenuItem<String>(
                value: loc.id,
                child: Text(loc.name),
              ),
          ],
          onChanged: (v) => setState(() {
            _selectedLocationId = (v != null && v.isNotEmpty) ? v : null;
            _isDirty = true;
          }),
        );
      },
    );
  }

  String? _validatePositivePrice(String? v) {
    final value = double.tryParse((v ?? '').trim().replaceAll(',', '.'));
    if (value == null) return 'Requerido';
    if (value <= 0) return 'Debe ser mayor a 0';
    return null;
  }

  String? _validateDiscountedPrice(String? v) {
    final value = double.tryParse((v ?? '').trim().replaceAll(',', '.'));
    if (value == null) return 'Requerido';
    if (value <= 0) return 'Debe ser mayor a 0';
    final original = _originalPriceValue;
    if (original != null && value >= original) {
      return 'Debe ser menor al precio original';
    }
    return null;
  }
}