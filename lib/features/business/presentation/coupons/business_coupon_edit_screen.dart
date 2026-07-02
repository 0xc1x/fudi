import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/ui/fudi_colors.dart';
import '../../../../core/ui/fudi_pressable_scale.dart';
import '../../../../core/ui/atoms/icons/fudi_icons.dart';
import '../../../../core/ui/fudi_spacing.dart';
import '../../../../core/ui/fudi_surface_card.dart';
import '../../../../core/ui/fudi_typography.dart';
import '../../../../core/ui/fudi_tips_card.dart';
import '../../../orders/domain/coupon.dart';
import '../business_providers.dart';
import 'coupon_components.dart';

const _codeAlphabet = 'ABCDEFGHJKMNPQRSTUVWXYZ23456789';
final _codeRandom = Random();

String _randomCouponCode({int length = 8}) {
  return List.generate(
    length,
    (_) => _codeAlphabet[_codeRandom.nextInt(_codeAlphabet.length)],
  ).join();
}

class _UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return newValue.copyWith(text: newValue.text.toUpperCase());
  }
}

class BusinessCouponEditScreen extends ConsumerStatefulWidget {
  const BusinessCouponEditScreen({this.couponId, super.key});
  final String? couponId;

  @override
  ConsumerState<BusinessCouponEditScreen> createState() =>
      _BusinessCouponEditScreenState();
}

class _BusinessCouponEditScreenState
    extends ConsumerState<BusinessCouponEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _valueController = TextEditingController();
  final _minPurchaseController = TextEditingController();
  final _usageLimitController = TextEditingController();

  var _type = 'percentage';
  var _isActive = true;
  DateTime? _expiryDate;
  var _loaded = false;
  var _saving = false;
  var _showExpiryError = false;

  bool get _isEdit => widget.couponId != null;

  bool get _canSave =>
      _codeController.text.trim().isNotEmpty &&
      _valueController.text.trim().isNotEmpty &&
      double.tryParse(_valueController.text.trim()) != null &&
      !_saving;

  @override
  void initState() {
    super.initState();
    _codeController.addListener(_onFormChanged);
    _valueController.addListener(_onFormChanged);
  }

  void _onFormChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _codeController.removeListener(_onFormChanged);
    _valueController.removeListener(_onFormChanged);
    _codeController.dispose();
    _valueController.dispose();
    _minPurchaseController.dispose();
    _usageLimitController.dispose();
    super.dispose();
  }

  /// Ahora se ejecuta de manera segura fuera del flujo de renderizado del build.
  void _hydrateOnce(Coupon coupon) {
    if (_loaded) return;
    _loaded = true;

    // Agendamos la asignación al final del frame actual para evitar colisiones de foco
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        _codeController.text = coupon.code;
        _valueController.text = coupon.value.toStringAsFixed(
          coupon.type == 'percentage' ? 0 : 2,
        );
        _minPurchaseController.text = coupon.minOrderAmount > 0
            ? coupon.minOrderAmount.toStringAsFixed(2)
            : '';
        _usageLimitController.text = coupon.maxUses?.toString() ?? '';
        _type = coupon.type;
        _isActive = coupon.isActive;
        _expiryDate = coupon.expiresAt;
      });
    });
  }

  void _generateCode() {
    setState(() => _codeController.text = _randomCouponCode());
  }

  Future<void> _selectExpiryDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _expiryDate ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: FudiColors.primary,
              onSurface: FudiColors.foreground,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _expiryDate = picked;
        _showExpiryError = false;
      });
    }
  }

  Future<void> _save(Coupon? existing) async {
    final formValid = _formKey.currentState!.validate();
    final hasExpiry = _expiryDate != null;

    if (!hasExpiry) setState(() => _showExpiryError = true);
    if (!formValid || !hasExpiry) return;

    setState(() => _saving = true);
    try {
      final business = await ref.read(currentBusinessProvider.future);
      if (business == null) return;
      final coupon = Coupon(
        id: existing?.id ?? '',
        businessId: business.id,
        code: _codeController.text.trim().toUpperCase(),
        name: existing?.name ?? _codeController.text.trim(),
        type: _type,
        value: double.tryParse(_valueController.text.trim()) ?? 0,
        minOrderAmount:
            double.tryParse(_minPurchaseController.text.trim()) ?? 0,
        maxUses: int.tryParse(_usageLimitController.text.trim()),
        usedCount: existing?.usedCount ?? 0,
        isActive: _isActive,
        expiresAt: _expiryDate,
      );
      await ref.read(businessCouponRepositoryProvider).upsertCoupon(coupon);
      ref.invalidate(businessCouponsProvider(business.id));
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'No se pudo guardar el cupón. Intenta de nuevo.',
              style: FudiTypography.bodyMedium.copyWith(color: Colors.white),
            ),
            backgroundColor: FudiColors.destructive,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(FudiRadius.md),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    Coupon? existingCoupon;

    // Si estamos editando, escuchamos de manera reactiva el estado del proveedor
    if (_isEdit) {
      final couponAsync = ref.watch(businessCouponProvider(widget.couponId!));

      // Usamos el .when interno para manejar la hidratación limpia e interceptar la data
      couponAsync.whenOrNull(
        data: (coupon) {
          existingCoupon = coupon;
          _hydrateOnce(coupon);
        },
      );

      // Si aún está cargando y no se ha hidratado localmente, mostramos esqueleto
      if (couponAsync.isLoading && !_loaded) {
        return const Scaffold(
          backgroundColor: Colors.white,
          appBar: _AppBar(isEdit: true),
          body: CouponEditFormSkeleton(),
        );
      }

      // Si arroja un error persistente y no hay datos previos cargados
      if (couponAsync.hasError && !_loaded) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: const _AppBar(isEdit: true),
          body: BusinessCouponErrorState(
            message: 'No pudimos cargar este cupón.',
            onRetry: () =>
                ref.invalidate(businessCouponProvider(widget.couponId!)),
          ),
        );
      }
    }

    // Renderizado unificado del body una vez que el estado local ha tomado control.
    return Scaffold(
      backgroundColor: FudiColors.muted.withValues(alpha: 0.4),
      appBar: _AppBar(isEdit: _isEdit),
      body: _FormBody(
        formKey: _formKey,
        codeController: _codeController,
        valueController: _valueController,
        minPurchaseController: _minPurchaseController,
        usageLimitController: _usageLimitController,
        type: _type,
        isActive: _isActive,
        expiryDate: _expiryDate,
        showExpiryError: _showExpiryError,
        onTypeChanged: (t) => setState(() => _type = t),
        onActiveChanged: (v) => setState(() => _isActive = v),
        onSelectDate: _selectExpiryDate,
        onGenerateCode: _generateCode,
      ),
      bottomNavigationBar: _BottomBar(
        isEdit: _isEdit,
        saving: _saving,
        canSave: _canSave,
        onSave: () => _save(existingCoupon),
      ),
    );
  }
}

// ─── AppBar ──────────────────────────────────────────────────────────
class _AppBar extends StatelessWidget implements PreferredSizeWidget {
  const _AppBar({required this.isEdit});
  final bool isEdit;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 4);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      leadingWidth: 56,
      leading: const BusinessCouponBackButton(),
      title: Text(
        isEdit ? 'Editar cupón' : 'Nuevo cupón',
        style: FudiTypography.h3.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }
}

// ─── Form Body ───────────────────────────────────────────────────────
class _FormBody extends StatelessWidget {
  const _FormBody({
    required this.formKey,
    required this.codeController,
    required this.valueController,
    required this.minPurchaseController,
    required this.usageLimitController,
    required this.type,
    required this.isActive,
    required this.expiryDate,
    required this.showExpiryError,
    required this.onTypeChanged,
    required this.onActiveChanged,
    required this.onSelectDate,
    required this.onGenerateCode,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController codeController;
  final TextEditingController valueController;
  final TextEditingController minPurchaseController;
  final TextEditingController usageLimitController;
  final String type;
  final bool isActive;
  final DateTime? expiryDate;
  final bool showExpiryError;
  final ValueChanged<String> onTypeChanged;
  final ValueChanged<bool> onActiveChanged;
  final VoidCallback onSelectDate;
  final VoidCallback onGenerateCode;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(
          horizontal: FudiSpacing.xl,
          vertical: FudiSpacing.lg,
        ),
        children: [
          _CodeSection(controller: codeController, onGenerate: onGenerateCode),
          const SizedBox(height: FudiSpacing.md),
          _DiscountTypeSection(
            type: type,
            onTypeChanged: onTypeChanged,
            valueController: valueController,
          ),
          const SizedBox(height: FudiSpacing.md),
          _ConditionsSection(minPurchaseController: minPurchaseController),
          const SizedBox(height: FudiSpacing.md),
          _ValiditySection(
            expiryDate: expiryDate,
            showError: showExpiryError,
            onSelectDate: onSelectDate,
            usageLimitController: usageLimitController,
          ),
          const SizedBox(height: FudiSpacing.md),
          _StatusSection(isActive: isActive, onActiveChanged: onActiveChanged),
          const SizedBox(height: FudiSpacing.lg),
          const FudiTipsCard(
            title: 'Consejos de conversión',
            tips: [
              'Los códigos cortos y memorables convierten mejor en redes sociales.',
              'Usa descuentos de entre el 10% y 20% para incentivar compras repetidas.',
              'Establece fechas límites de expiración claras para generar urgencia.',
              'Limita la cantidad de usos máximos para proteger tu presupuesto diario.',
            ],
          ),
          const SizedBox(height: FudiSpacing.xxl),
        ],
      ),
    );
  }
}

// ─── Code Section ────────────────────────────────────────────────────
class _CodeSection extends StatelessWidget {
  const _CodeSection({required this.controller, required this.onGenerate});
  final TextEditingController controller;
  final VoidCallback onGenerate;

  @override
  Widget build(BuildContext context) {
    return FudiSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(FudiIcons.tag, size: 18, color: FudiColors.primary),
              const SizedBox(width: FudiSpacing.xs),
              Text(
                'Código del cupón',
                style: FudiTypography.labelSmall.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: FudiSpacing.md),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextFormField(
                  controller: controller,
                  textCapitalization: TextCapitalization.characters,
                  maxLength: 20,
                  inputFormatters: [
                    FilteringTextInputFormatter.deny(RegExp(r'\s')),
                    _UpperCaseTextFormatter(),
                  ],
                  style: FudiTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.1,
                  ),
                  decoration: couponInputDecoration(hint: 'EJ. PROMO2026'),
                  validator: (v) {
                    final trimmed = v?.trim() ?? '';
                    if (trimmed.isEmpty) return 'El código es obligatorio';
                    if (trimmed.length < 3) {
                      return 'Debe tener al menos 3 caracteres';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: FudiSpacing.sm),
              Semantics(
                label: 'Generar código aleatorio',
                button: true,
                child: FudiPressableScale(
                  onTap: onGenerate,
                  child: Container(
                    height: 48,
                    padding: const EdgeInsets.symmetric(
                      horizontal: FudiSpacing.lg,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(FudiRadius.md),
                      border: Border.all(
                        color: FudiColors.primary.withValues(alpha: 0.5),
                      ),
                      color: FudiColors.primary.withValues(alpha: 0.04),
                    ),
                    child: Center(
                      child: Text(
                        'Generar',
                        style: FudiTypography.bodyMedium.copyWith(
                          color: FudiColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: FudiSpacing.xs),
          Text(
            'El identificador único que tus clientes ingresarán antes del checkout.',
            style: FudiTypography.bodySmall.copyWith(
              color: FudiColors.mutedForeground,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Discount Type Section ───────────────────────────────────────────
class _DiscountTypeSection extends StatelessWidget {
  const _DiscountTypeSection({
    required this.type,
    required this.onTypeChanged,
    required this.valueController,
  });

  final String type;
  final ValueChanged<String> onTypeChanged;
  final TextEditingController valueController;

  @override
  Widget build(BuildContext context) {
    final isPercentage = type == 'percentage';

    return FudiSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tipo de beneficio',
            style: FudiTypography.labelSmall.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: FudiSpacing.md),
          Row(
            children: [
              Expanded(
                child: _TypeOption(
                  icon: Icons.percent_rounded,
                  label: 'Porcentaje',
                  selected: isPercentage,
                  onTap: () => onTypeChanged('percentage'),
                ),
              ),
              const SizedBox(width: FudiSpacing.sm),
              Expanded(
                child: _TypeOption(
                  icon: Icons.attach_money_rounded,
                  label: 'Monto fijo',
                  selected: !isPercentage,
                  onTap: () => onTypeChanged('fixed'),
                ),
              ),
            ],
          ),
          const SizedBox(height: FudiSpacing.lg),
          Text(
            'Valor del descuento *',
            style: FudiTypography.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: FudiSpacing.sm),
          TextFormField(
            controller: valueController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
            ],
            style: FudiTypography.bodyMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
            decoration: couponInputDecoration(
              hint: isPercentage ? '15' : '5.00',
              prefix: Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Text(
                  isPercentage ? '%' : '\$',
                  style: FudiTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: FudiColors.mutedForeground,
                  ),
                ),
              ),
            ),
            validator: (v) {
              final trimmed = v?.trim() ?? '';
              if (trimmed.isEmpty) return 'Este valor es requerido';
              final parsed = double.tryParse(trimmed);
              if (parsed == null) return 'Ingresa un número válido';
              if (parsed <= 0) return 'Debe ser mayor que cero';
              if (isPercentage && parsed > 100) {
                return 'El porcentaje máximo es 100%';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }
}

class _TypeOption extends StatelessWidget {
  const _TypeOption({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      button: true,
      selected: selected,
      child: FudiPressableScale(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(
            vertical: FudiSpacing.md,
            horizontal: FudiSpacing.lg,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(FudiRadius.md),
            border: Border.all(
              color: selected ? FudiColors.primary : FudiColors.borderSolid,
              width: selected ? 1.5 : 1,
            ),
            color: selected
                ? FudiColors.primary.withValues(alpha: 0.05)
                : Colors.white,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: selected
                    ? FudiColors.primary
                    : FudiColors.mutedForeground,
              ),
              const SizedBox(width: FudiSpacing.xs),
              Text(
                label,
                style: FudiTypography.bodyMedium.copyWith(
                  fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                  color: selected ? FudiColors.primary : FudiColors.foreground,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Conditions Section ──────────────────────────────────────────────
class _ConditionsSection extends StatelessWidget {
  const _ConditionsSection({required this.minPurchaseController});
  final TextEditingController minPurchaseController;

  @override
  Widget build(BuildContext context) {
    return FudiSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Condiciones de uso',
            style: FudiTypography.labelSmall.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: FudiSpacing.md),
          Text(
            'Monto mínimo de compra (opcional)',
            style: FudiTypography.bodyMedium.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: FudiSpacing.sm),
          TextFormField(
            controller: minPurchaseController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
            ],
            style: FudiTypography.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
            decoration: couponInputDecoration(
              hint: '0.00',
              prefix: Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Text(
                  '\$',
                  style: FudiTypography.bodyMedium.copyWith(
                    color: FudiColors.mutedForeground,
                  ),
                ),
              ),
            ),
            validator: (v) {
              final trimmed = v?.trim() ?? '';
              if (trimmed.isEmpty) return null;
              final parsed = double.tryParse(trimmed);
              if (parsed == null || parsed < 0) {
                return 'Monto de orden inválido';
              }
              return null;
            },
          ),
          const SizedBox(height: FudiSpacing.xs),
          Text(
            'El cupón solo se activará si el carrito del cliente supera este umbral.',
            style: FudiTypography.bodySmall.copyWith(
              color: FudiColors.mutedForeground,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Validity Section ────────────────────────────────────────────────
class _ValiditySection extends StatelessWidget {
  const _ValiditySection({
    required this.expiryDate,
    required this.showError,
    required this.onSelectDate,
    required this.usageLimitController,
  });

  final DateTime? expiryDate;
  final bool showError;
  final VoidCallback onSelectDate;
  final TextEditingController usageLimitController;

  @override
  Widget build(BuildContext context) {
    final hasError = showError && expiryDate == null;

    return FudiSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Vigencia y Límites',
            style: FudiTypography.labelSmall.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: FudiSpacing.md),
          Text(
            'Fecha de expiración *',
            style: FudiTypography.bodyMedium.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: FudiSpacing.sm),
          Semantics(
            label: expiryDate != null
                ? 'Fecha de expiración: ${formatLongDate(expiryDate!)}'
                : 'Seleccionar fecha de expiración',
            button: true,
            child: GestureDetector(
              onTap: onSelectDate,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: FudiSpacing.lg,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: FudiColors.inputBackground.withValues(alpha: 0.5),
                  border: Border.all(
                    color: hasError
                        ? FudiColors.destructive
                        : FudiColors.borderSolid,
                    width: hasError ? 1.5 : 1,
                  ),
                  borderRadius: BorderRadius.circular(FudiRadius.md),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 16,
                      color: hasError
                          ? FudiColors.destructive
                          : FudiColors.mutedForeground,
                    ),
                    const SizedBox(width: FudiSpacing.sm),
                    Text(
                      expiryDate != null
                          ? formatLongDate(expiryDate!)
                          : 'Elegir fecha de vencimiento',
                      style: FudiTypography.bodyMedium.copyWith(
                        fontWeight: expiryDate != null
                            ? FontWeight.w600
                            : FontWeight.normal,
                        color: expiryDate != null
                            ? FudiColors.foreground
                            : FudiColors.mutedForeground,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (hasError) ...[
            const SizedBox(height: FudiSpacing.xs),
            Text(
              'Es obligatorio fijar una fecha de vigencia para el cupón.',
              style: FudiTypography.bodySmall.copyWith(
                color: FudiColors.destructive,
              ),
            ),
          ],
          const SizedBox(height: FudiSpacing.lg),
          Text(
            'Límite total de redenciones (opcional)',
            style: FudiTypography.bodyMedium.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: FudiSpacing.sm),
          TextFormField(
            controller: usageLimitController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: FudiTypography.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
            decoration: couponInputDecoration(hint: 'Sin límite (Ilimitado)'),
            validator: (v) {
              final trimmed = v?.trim() ?? '';
              if (trimmed.isEmpty) return null;
              final parsed = int.tryParse(trimmed);
              if (parsed == null || parsed <= 0) {
                return 'Debe ser una cantidad válida mayor a 0';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }
}

// ─── Status Section ──────────────────────────────────────────────────
class _StatusSection extends StatelessWidget {
  const _StatusSection({required this.isActive, required this.onActiveChanged});
  final bool isActive;
  final ValueChanged<bool> onActiveChanged;

  @override
  Widget build(BuildContext context) {
    return FudiSurfaceCard(
      padding: const EdgeInsets.symmetric(
        horizontal: FudiSpacing.lg,
        vertical: FudiSpacing.md,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Disponibilidad de la oferta',
                  style: FudiTypography.labelSmall.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Si se desactiva, ningún cliente podrá aplicar el código.',
                  style: FudiTypography.bodySmall.copyWith(
                    color: FudiColors.mutedForeground,
                  ),
                ),
              ],
            ),
          ),
          Semantics(
            label: 'Estado del cupón activo',
            toggled: isActive,
            child: Switch(
              value: isActive,
              activeThumbColor: Colors.white,
              activeTrackColor: FudiColors.primary,
              inactiveThumbColor: Colors.white,
              inactiveTrackColor: FudiColors.borderSolid,
              trackOutlineColor: const WidgetStatePropertyAll(
                Colors.transparent,
              ),
              onChanged: onActiveChanged,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Bottom Bar ──────────────────────────────────────────────────────
class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.isEdit,
    required this.saving,
    required this.canSave,
    required this.onSave,
  });

  final bool isEdit;
  final bool saving;
  final bool canSave;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final enabled = canSave && !saving;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: FudiColors.borderSolid)),
      ),
      padding: const EdgeInsets.all(FudiSpacing.lg),
      child: SafeArea(
        top: false,
        child: Semantics(
          label: isEdit
              ? 'Guardar modificaciones'
              : 'Confirmar y publicar cupón',
          button: true,
          enabled: enabled,
          child: FudiPressableScale(
            onTap: enabled ? onSave : null,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: enabled ? FudiColors.primary : FudiColors.muted,
                borderRadius: BorderRadius.circular(FudiRadius.md),
              ),
              child: Text(
                isEdit ? 'Guardar cambios' : 'Publicar cupón',
                textAlign: TextAlign.center,
                style: FudiTypography.bodyMedium.copyWith(
                  color: enabled ? Colors.white : FudiColors.mutedForeground,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
