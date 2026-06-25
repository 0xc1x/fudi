import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/ui/fudi_colors.dart';
import '../../../../core/ui/fudi_pressable_scale.dart';
import '../../../../core/ui/atoms/icons/fudi_icons.dart';
import '../../../../core/ui/fudi_spacing.dart';
import '../../../../core/ui/fudi_surface_card.dart';
import '../../../../core/ui/fudi_typography.dart';
import '../../../orders/domain/coupon.dart';
import '../business_providers.dart';

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

  bool get _isEdit => widget.couponId != null;

  @override
  void dispose() {
    _codeController.dispose();
    _valueController.dispose();
    _minPurchaseController.dispose();
    _usageLimitController.dispose();
    super.dispose();
  }

  void _hydrate(Coupon coupon) {
    if (_loaded) return;
    _loaded = true;
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
  }

  void _generateCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final buffer = StringBuffer();
    for (var i = 0; i < 8; i++) {
      buffer.write(chars[DateTime.now().microsecondsSinceEpoch % chars.length]);
    }
    setState(() => _codeController.text = buffer.toString());
  }

  Future<void> _selectExpiryDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _expiryDate ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (picked != null) setState(() => _expiryDate = picked);
  }

  Future<void> _save(Coupon? existing) async {
    if (!_formKey.currentState!.validate()) return;
    if (_expiryDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona una fecha de expiración')),
      );
      return;
    }

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
        value: double.tryParse(_valueController.text) ?? 0,
        minOrderAmount: double.tryParse(_minPurchaseController.text) ?? 0,
        maxUses: int.tryParse(_usageLimitController.text),
        usedCount: existing?.usedCount ?? 0,
        isActive: _isActive,
        expiresAt: _expiryDate,
      );
      await ref.read(businessCouponRepositoryProvider).upsertCoupon(coupon);
      ref.invalidate(businessCouponsProvider(business.id));
      if (mounted) context.pop();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final couponAsync = _isEdit
        ? ref.watch(businessCouponProvider(widget.couponId!))
        : null;

    return Scaffold(
      backgroundColor: FudiColors.muted,
      appBar: _AppBar(isEdit: _isEdit),
      body:
          couponAsync?.when(
            data: (coupon) {
              _hydrate(coupon);
              return _FormBody(
                formKey: _formKey,
                codeController: _codeController,
                valueController: _valueController,
                minPurchaseController: _minPurchaseController,
                usageLimitController: _usageLimitController,
                type: _type,
                isActive: _isActive,
                expiryDate: _expiryDate,
                onTypeChanged: (t) => setState(() => _type = t),
                onActiveChanged: (v) => setState(() => _isActive = v),
                onSelectDate: _selectExpiryDate,
                onGenerateCode: _generateCode,
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('$e')),
          ) ??
          _FormBody(
            formKey: _formKey,
            codeController: _codeController,
            valueController: _valueController,
            minPurchaseController: _minPurchaseController,
            usageLimitController: _usageLimitController,
            type: _type,
            isActive: _isActive,
            expiryDate: _expiryDate,
            onTypeChanged: (t) => setState(() => _type = t),
            onActiveChanged: (v) => setState(() => _isActive = v),
            onSelectDate: _selectExpiryDate,
            onGenerateCode: _generateCode,
          ),
      bottomNavigationBar: _BottomBar(
        isEdit: _isEdit,
        saving: _saving,
        canSave:
            _codeController.text.isNotEmpty &&
            _valueController.text.isNotEmpty &&
            _expiryDate != null,
        onSave: () => _save(couponAsync?.asData?.value),
      ),
    );
  }
}

class _AppBar extends StatelessWidget implements PreferredSizeWidget {
  const _AppBar({required this.isEdit});
  final bool isEdit;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: Padding(
        padding: const EdgeInsets.only(left: FudiSpacing.sm),
        child: FudiPressableScale(
          onTap: () => context.pop(),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: FudiColors.muted,
              shape: BoxShape.circle,
            ),
            child: const Icon(FudiIcons.chevronLeft, size: 20),
          ),
        ),
      ),
      title: Text(
        isEdit ? 'Editar cupón' : 'Nuevo cupón',
        style: FudiTypography.h4,
      ),
      backgroundColor: FudiColors.background,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 1,
      shadowColor: Colors.black12,
    );
  }
}

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
  final ValueChanged<String> onTypeChanged;
  final ValueChanged<bool> onActiveChanged;
  final VoidCallback onSelectDate;
  final VoidCallback onGenerateCode;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: ListView(
        padding: const EdgeInsets.all(FudiSpacing.lg),
        children: [
          _CodeSection(controller: codeController, onGenerate: onGenerateCode),
          const SizedBox(height: FudiSpacing.lg),
          _DiscountTypeSection(
            type: type,
            onTypeChanged: onTypeChanged,
            valueController: valueController,
          ),
          const SizedBox(height: FudiSpacing.lg),
          _ConditionsSection(
            type: type,
            minPurchaseController: minPurchaseController,
          ),
          const SizedBox(height: FudiSpacing.lg),
          _ValiditySection(
            expiryDate: expiryDate,
            onSelectDate: onSelectDate,
            usageLimitController: usageLimitController,
          ),
          const SizedBox(height: FudiSpacing.lg),
          _StatusSection(isActive: isActive, onActiveChanged: onActiveChanged),
          const SizedBox(height: FudiSpacing.lg),
          _TipsCard(),
          const SizedBox(height: FudiSpacing.xxl),
        ],
      ),
    );
  }
}

class _CodeSection extends StatelessWidget {
  const _CodeSection({required this.controller, required this.onGenerate});

  final TextEditingController controller;
  final VoidCallback onGenerate;

  @override
  Widget build(BuildContext context) {
    return FudiSurfaceCard(
      padding: const EdgeInsets.all(FudiSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(FudiIcons.tag, size: 20, color: FudiColors.primary),
              const SizedBox(width: FudiSpacing.sm),
              Text('Código del cupón', style: FudiTypography.labelSmall),
            ],
          ),
          const SizedBox(height: FudiSpacing.md),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: controller,
                  textCapitalization: TextCapitalization.characters,
                  maxLength: 20,
                  decoration: InputDecoration(
                    hintText: 'CODIGO2026',
                    counterText: '',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(FudiRadius.xl),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: FudiSpacing.lg,
                      vertical: FudiSpacing.md,
                    ),
                  ),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Requerido' : null,
                ),
              ),
              const SizedBox(width: FudiSpacing.sm),
              FudiPressableScale(
                onTap: onGenerate,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: FudiSpacing.lg,
                    vertical: FudiSpacing.md + 4,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(FudiRadius.xl),
                    border: Border.all(color: FudiColors.primary),
                  ),
                  child: const Text('Generar', style: TextStyle(color: FudiColors.primary)),
                ),
              ),
            ],
          ),
          const SizedBox(height: FudiSpacing.xs),
          Text(
            'Código único que los clientes usarán al hacer pedidos',
            style: FudiTypography.bodySmall,
          ),
        ],
      ),
    );
  }
}

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
    return FudiSurfaceCard(
      padding: const EdgeInsets.all(FudiSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Tipo de descuento', style: FudiTypography.labelSmall),
          const SizedBox(height: FudiSpacing.md),
          Row(
            children: [
              Expanded(
                child: _TypeOption(
                  icon: Icons.percent_rounded,
                  label: 'Porcentaje',
                  selected: type == 'percentage',
                  onTap: () => onTypeChanged('percentage'),
                ),
              ),
              const SizedBox(width: FudiSpacing.md),
              Expanded(
                child: _TypeOption(
                  icon: Icons.attach_money_rounded,
                  label: 'Monto fijo',
                  selected: type == 'fixed',
                  onTap: () => onTypeChanged('fixed'),
                ),
              ),
            ],
          ),
          const SizedBox(height: FudiSpacing.lg),
          Text(
            'Valor del descuento *',
            style: FudiTypography.bodyMedium.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: FudiSpacing.sm),
          TextFormField(
            controller: valueController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              prefixText: type == 'percentage' ? '% ' : '\$ ',
              hintText: type == 'percentage' ? '10' : '1.50',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(FudiRadius.xl),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: FudiSpacing.lg,
                vertical: FudiSpacing.md,
              ),
            ),
            validator: (v) =>
                v == null || v.trim().isEmpty ? 'Requerido' : null,
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
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(FudiSpacing.lg),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(FudiRadius.xl),
          border: Border.all(
            color: selected ? FudiColors.primary : FudiColors.borderSolid,
            width: selected ? 2 : 1,
          ),
          color: selected ? FudiColors.primary.withValues(alpha: 0.05) : null,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 24,
              color: selected ? FudiColors.primary : FudiColors.mutedForeground,
            ),
            const SizedBox(height: FudiSpacing.xs),
            Text(
              label,
              style: FudiTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.w500,
                color: selected ? FudiColors.primary : FudiColors.foreground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConditionsSection extends StatelessWidget {
  const _ConditionsSection({
    required this.type,
    required this.minPurchaseController,
  });

  final String type;
  final TextEditingController minPurchaseController;

  @override
  Widget build(BuildContext context) {
    return FudiSurfaceCard(
      padding: const EdgeInsets.all(FudiSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Condiciones', style: FudiTypography.labelSmall),
          const SizedBox(height: FudiSpacing.md),
          Text(
            'Compra mínima (opcional)',
            style: FudiTypography.bodyMedium.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: FudiSpacing.sm),
          TextFormField(
            controller: minPurchaseController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              prefixText: '\$ ',
              hintText: '0.00',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(FudiRadius.xl),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: FudiSpacing.lg,
                vertical: FudiSpacing.md,
              ),
            ),
          ),
          const SizedBox(height: FudiSpacing.xs),
          Text(
            'Monto mínimo del pedido para aplicar el cupón',
            style: FudiTypography.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _ValiditySection extends StatelessWidget {
  const _ValiditySection({
    required this.expiryDate,
    required this.onSelectDate,
    required this.usageLimitController,
  });

  final DateTime? expiryDate;
  final VoidCallback onSelectDate;
  final TextEditingController usageLimitController;

  @override
  Widget build(BuildContext context) {
    return FudiSurfaceCard(
      padding: const EdgeInsets.all(FudiSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Validez', style: FudiTypography.labelSmall),
          const SizedBox(height: FudiSpacing.md),
          Text(
            'Fecha de expiración *',
            style: FudiTypography.bodyMedium.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: FudiSpacing.sm),
          GestureDetector(
            onTap: onSelectDate,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: FudiSpacing.lg,
                vertical: FudiSpacing.md + 2,
              ),
              decoration: BoxDecoration(
                border: Border.all(color: FudiColors.borderSolid),
                borderRadius: BorderRadius.circular(FudiRadius.xl),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 18,
                    color: FudiColors.mutedForeground,
                  ),
                  const SizedBox(width: FudiSpacing.sm),
                  Text(
                    expiryDate != null
                        ? _formatDate(expiryDate!)
                        : 'Seleccionar fecha',
                    style: FudiTypography.bodyMedium.copyWith(
                      color: expiryDate != null
                          ? FudiColors.foreground
                          : FudiColors.mutedForeground,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: FudiSpacing.lg),
          Text(
            'Límite de usos (opcional)',
            style: FudiTypography.bodyMedium.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: FudiSpacing.sm),
          TextFormField(
            controller: usageLimitController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'Ilimitado',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(FudiRadius.xl),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: FudiSpacing.lg,
                vertical: FudiSpacing.md,
              ),
            ),
          ),
          const SizedBox(height: FudiSpacing.xs),
          Text(
            'Número máximo de veces que se puede usar este cupón',
            style: FudiTypography.bodySmall,
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      '',
      'enero',
      'febrero',
      'marzo',
      'abril',
      'mayo',
      'junio',
      'julio',
      'agosto',
      'septiembre',
      'octubre',
      'noviembre',
      'diciembre',
    ];
    return '${date.day} de ${months[date.month]} de ${date.year}';
  }
}

class _StatusSection extends StatelessWidget {
  const _StatusSection({required this.isActive, required this.onActiveChanged});

  final bool isActive;
  final ValueChanged<bool> onActiveChanged;

  @override
  Widget build(BuildContext context) {
    return FudiSurfaceCard(
      padding: const EdgeInsets.all(FudiSpacing.lg),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Cupón activo', style: FudiTypography.labelSmall),
                const SizedBox(height: FudiSpacing.xs),
                Text(
                  'Los clientes podrán usar este cupón',
                  style: FudiTypography.bodySmall,
                ),
              ],
            ),
          ),
          Switch(
            value: isActive,
            activeThumbColor: FudiColors.primary,
            activeTrackColor: FudiColors.primary.withValues(alpha: 0.4),
            onChanged: onActiveChanged,
          ),
        ],
      ),
    );
  }
}

class _TipsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(FudiSpacing.lg),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(FudiRadius.xxl),
        border: Border.all(color: const Color(0xFFBFDBFE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Consejos',
            style: FudiTypography.labelSmall.copyWith(
              color: const Color(0xFF1E3A5F),
            ),
          ),
          const SizedBox(height: FudiSpacing.sm),
          _tip('Códigos cortos y memorables funcionan mejor'),
          _tip('Usa descuentos del 10-20% para atraer clientes nuevos'),
          _tip('Establece fechas de expiración para crear urgencia'),
          _tip('Limita los usos para controlar el presupuesto'),
        ],
      ),
    );
  }

  Widget _tip(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: FudiSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• ',
            style: FudiTypography.bodySmall.copyWith(
              color: const Color(0xFF1D4ED8),
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: FudiTypography.bodySmall.copyWith(
                color: const Color(0xFF1D4ED8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

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
    return Container(
      decoration: BoxDecoration(
        color: FudiColors.background,
        border: Border(top: BorderSide(color: FudiColors.borderSolid)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(FudiSpacing.lg),
      child: FudiPressableScale(
        onTap: (saving || !canSave) ? null : onSave,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: FudiSpacing.lg),
          decoration: BoxDecoration(
            color: canSave ? FudiColors.primary : FudiColors.muted,
            borderRadius: BorderRadius.circular(FudiRadius.xl),
          ),
          child: Center(
            child: saving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    isEdit ? 'Guardar cambios' : 'Crear cupón',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
