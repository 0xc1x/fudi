import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../core/ui/fudi_colors.dart';
import '../../../../core/ui/fudi_spacing.dart';
import '../../../../core/ui/fudi_typography.dart';
import '../business_providers.dart';

/// Shows a modal bottom sheet with a QR scanner for pickup code validation.
///
/// When a valid Fudi pickup QR is detected, it automatically validates the
/// code via the server-side RPC. On success, resolves with `true`.
/// On failure or manual dismiss, resolves with `false`.
Future<bool> showPickupScannerSheet(
  BuildContext context,
  WidgetRef ref, {
  required String expectedOrderId,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => _PickupScannerSheet(expectedOrderId: expectedOrderId),
  ).then((r) => r ?? false);
}

class _PickupScannerSheet extends ConsumerStatefulWidget {
  const _PickupScannerSheet({required this.expectedOrderId});

  final String expectedOrderId;

  @override
  ConsumerState<_PickupScannerSheet> createState() =>
      _PickupScannerSheetState();
}

class _PickupScannerSheetState extends ConsumerState<_PickupScannerSheet> {
  final _scannerController = MobileScannerController();
  String? _scannedValue;
  bool _isValidating = false;
  bool? _isSuccess;

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.7,
        child: Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: FudiColors.mutedForeground.withAlpha(80),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: FudiSpacing.lg),
            Text('Escanear código QR', style: FudiTypography.h3),
            const SizedBox(height: FudiSpacing.xs),
            Text(
              'Apunta la cámara al código QR del cliente',
              style: FudiTypography.bodySmall.copyWith(
                color: FudiColors.mutedForeground,
              ),
            ),
            const SizedBox(height: FudiSpacing.lg),
            // Scanner preview
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    children: [
                      MobileScanner(
                        controller: _scannerController,
                        onDetect: _onBarcodeDetect,
                      ),
                      if (_isValidating || _isSuccess != null)
                        Container(
                          color: Colors.black54,
                          alignment: Alignment.center,
                          child: _buildOverlay(),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            if (_scannedValue != null && _isSuccess == null)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'QR detectado: $_scannedValue',
                  style: FudiTypography.bodySmall,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            const SizedBox(height: FudiSpacing.md),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _canCancel
                      ? () => Navigator.of(context).pop(false)
                      : null,
                  icon: const Icon(Icons.close, size: 20),
                  label: const Text('Cancelar'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: FudiSpacing.lg),
          ],
        ),
      ),
    );
  }

  bool get _canCancel => _isSuccess != true;

  Widget _buildOverlay() {
    if (_isValidating) {
      return const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: Colors.white),
          SizedBox(height: 12),
          Text(
            'Validando código...',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ],
      );
    }

    if (_isSuccess == true) {
      return const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle, color: Colors.greenAccent, size: 64),
          SizedBox(height: 12),
          Text(
            '¡Entrega validada!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.error, color: Colors.redAccent, size: 64),
        const SizedBox(height: 12),
        const Text(
          'Código inválido',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _scannedValue ?? '',
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: _resetScanner,
          child: const Text('Escanear de nuevo'),
        ),
      ],
    );
  }

  void _resetScanner() {
    setState(() {
      _scannedValue = null;
      _isValidating = false;
      _isSuccess = null;
    });
    _scannerController.start();
  }

  void _onBarcodeDetect(BarcodeCapture capture) {
    if (_isValidating || _isSuccess != null) return;
    if (capture.barcodes.isEmpty) return;

    final rawValue = capture.barcodes.first.rawValue;
    if (rawValue == null || rawValue.isEmpty) return;

    _scannerController.stop();
    setState(() {
      _scannedValue = rawValue;
    });

    _validateQrCode(rawValue);
  }

  Future<void> _validateQrCode(String qrData) async {
    // Parse: fudi://pickup/{orderId}/{pickupCode}
    final uri = Uri.tryParse(qrData);
    if (uri == null ||
        uri.scheme != 'fudi' ||
        uri.host != 'pickup' ||
        uri.pathSegments.length != 2) {
      setState(() => _isSuccess = false);
      return;
    }

    final qrOrderId = uri.pathSegments[0];
    final qrPickupCode = uri.pathSegments[1];

    if (qrOrderId.isEmpty || qrPickupCode.isEmpty) {
      setState(() => _isSuccess = false);
      return;
    }

    if (qrOrderId != widget.expectedOrderId) {
      setState(() => _isSuccess = false);
      return;
    }

    setState(() => _isValidating = true);

    try {
      final repo = ref.read(businessOrderRepositoryProvider);
      final result = await repo.validatePickupCode(
        orderId: qrOrderId,
        pickupCode: qrPickupCode,
      );

      if (!mounted) return;

      if (result.success) {
        setState(() => _isSuccess = true);
        await Future.delayed(const Duration(seconds: 1));
        if (!context.mounted) return;
        Navigator.of(context).pop(true);
      } else {
        setState(() => _isSuccess = false);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSuccess = false);
    }
  }
}
