import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

/// Renders [payload] as a QR code image inside an optional styled card.
class QrCodeWidget extends StatelessWidget {
  final String payload;
  final double size;
  final Color foregroundColor;
  final Color backgroundColor;
  final bool showCard;

  const QrCodeWidget({
    super.key,
    required this.payload,
    this.size = 200,
    this.foregroundColor = Colors.black,
    this.backgroundColor = Colors.white,
    this.showCard = true,
  });

  @override
  Widget build(BuildContext context) {
    final qr = QrImageView(
      data: payload,
      version: QrVersions.auto,
      size: size,
      eyeStyle: QrEyeStyle(
        eyeShape: QrEyeShape.square,
        color: foregroundColor,
      ),
      dataModuleStyle: QrDataModuleStyle(
        dataModuleShape: QrDataModuleShape.square,
        color: foregroundColor,
      ),
      backgroundColor: backgroundColor,
      errorCorrectionLevel: QrErrorCorrectLevel.M,
    );

    if (!showCard) return qr;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: qr,
    );
  }
}
