import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../fudi_spacing.dart';

class PickupCodeQr extends StatelessWidget {
  const PickupCodeQr({
    required this.orderId,
    required this.pickupCode,
    this.size = 180,
    super.key,
  });

  final String orderId;
  final String pickupCode;
  final double size;

  String get _qrData => 'fudi://pickup/$orderId/$pickupCode';

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(FudiSpacing.xs),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: QrImageView(
        data: _qrData,
        version: QrVersions.auto,
        size: size,
        eyeStyle: const QrEyeStyle(
          eyeShape: QrEyeShape.square,
          color: Colors.black,
        ),
        dataModuleStyle: const QrDataModuleStyle(
          dataModuleShape: QrDataModuleShape.square,
          color: Colors.black,
        ),
      ),
    );
  }
}
