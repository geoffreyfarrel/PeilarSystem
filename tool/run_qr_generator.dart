// ignore_for_file: avoid_print

import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:peilar_superapp/features/qr_scanner/domain/mock/qr_mock_generator.dart';
import 'package:peilar_superapp/features/qr_scanner/domain/entities/qr_payment.dart';
import 'package:qr/qr.dart';

const _outputDir = 'tool/mock/qr';
const _moduleScale = 10; // pixels per QR module
const _padding = 40;     // quiet zone in pixels

void main() {
  Directory(_outputDir).createSync(recursive: true);

  print('=== Dynamic QR (3 samples) ===');
  for (var i = 1; i <= 3; i++) {
    final mock = QrMockGenerator.createDynamic();
    _logAndSave(i, 'dynamic', mock.data, mock.rawPayload);
  }

  print('\n=== Static QR (3 samples) ===');
  for (var i = 1; i <= 3; i++) {
    final mock = QrMockGenerator.createStatic();
    _logAndSave(i, 'static', mock.data, mock.rawPayload);
  }

  print('\nSaved to $_outputDir/');
}

void _logAndSave(int n, String kind, QrPaymentData d, String raw) {
  print('[$n] ${d.merchantName} (${d.merchantCategory})');
  if (d.fixedAmount != null) print('    amount  : ${d.fixedAmount} ${d.currency}');
  if (d.reference != null)   print('    ref     : ${d.reference}');
  print('    payload : $raw');

  final fileName = _fileName(n, kind, d);
  _saveJpg(raw, '$_outputDir/$fileName');
  print('    saved   : $_outputDir/$fileName\n');
}

// ── QR → JPEG renderer ───────────────────────────────────────────────────────

void _saveJpg(String payload, String path) {
  final qrCode = QrCode.fromData(
    data: payload,
    errorCorrectLevel: QrErrorCorrectLevel.M,
  );
  final qrImage = QrImage(qrCode);
  final modules = qrImage.moduleCount;

  final side = modules * _moduleScale + _padding * 2;
  final bitmap = img.Image(width: side, height: side);

  // White background
  img.fill(bitmap, color: img.ColorRgb8(255, 255, 255));

  // Black modules
  for (var row = 0; row < modules; row++) {
    for (var col = 0; col < modules; col++) {
      if (qrImage.isDark(row, col)) {
        final x0 = _padding + col * _moduleScale;
        final y0 = _padding + row * _moduleScale;
        for (var dy = 0; dy < _moduleScale; dy++) {
          for (var dx = 0; dx < _moduleScale; dx++) {
            bitmap.setPixelRgb(x0 + dx, y0 + dy, 0, 0, 0);
          }
        }
      }
    }
  }

  File(path).writeAsBytesSync(img.encodeJpg(bitmap, quality: 95));
}

// ── Helpers ───────────────────────────────────────────────────────────────────

String _fileName(int n, String kind, QrPaymentData d) {
  final safeName = d.merchantName
      .replaceAll("'", '')
      .replaceAll(' ', '_')
      .toLowerCase();
  if (kind == 'dynamic') {
    final amt = d.fixedAmount!;
    final amtStr = amt % 1 == 0 ? amt.toInt().toString() : amt.toStringAsFixed(2);
    return '${kind}_${n}_${safeName}_$amtStr${d.currency}.jpg';
  }
  return '${kind}_${n}_$safeName.jpg';
}
