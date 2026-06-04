import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../landing/presentation/providers/language_provider.dart';
import '../../domain/entities/qr_payment.dart';
import '../providers/payment_provider.dart';

class QrScannerPage extends ConsumerStatefulWidget {
  const QrScannerPage({super.key});

  @override
  ConsumerState<QrScannerPage> createState() => _QrScannerPageState();
}

class _QrScannerPageState extends ConsumerState<QrScannerPage>
    with SingleTickerProviderStateMixin {
  late final MobileScannerController _scanner;
  late final AnimationController _scanLineController;
  late final Animation<double> _scanLineAnim;
  bool _scanned = false;
  bool _flashOn = false;

  static const double _cutoutSize = 260.0;

  @override
  void initState() {
    super.initState();
    _scanner = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
    );
    _scanLineController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _scanLineAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _scanLineController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scanner.dispose();
    _scanLineController.dispose();
    super.dispose();
  }

  void _handleDetect(BarcodeCapture capture) {
    if (_scanned) return;
    final raw = capture.barcodes.firstOrNull?.rawValue;
    if (raw == null || raw.isEmpty) return;
    _navigateToPayment(QrPaymentData.parse(raw));
  }

  void _navigateToPayment(QrPaymentData data) {
    if (_scanned) return;
    setState(() => _scanned = true);
    _scanner.stop();
    ref.read(paymentProvider.notifier).loadQrData(data);
    context.go('/payment');
  }

  void _toggleFlash() {
    _scanner.toggleTorch();
    setState(() => _flashOn = !_flashOn);
  }

  @override
  Widget build(BuildContext context) {
    final text = ref.watch(appTextProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera feed
          MobileScanner(
            controller: _scanner,
            onDetect: _handleDetect,
          ),

          // Overlay with cutout
          AnimatedBuilder(
            animation: _scanLineAnim,
            builder: (context, _) {
              return CustomPaint(
                painter: _ScannerOverlayPainter(
                  cutoutSize: _cutoutSize,
                  scanProgress: _scanLineAnim.value,
                ),
                child: const SizedBox.expand(),
              );
            },
          ),

          // Top bar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  _IconBtn(
                    icon: Icons.arrow_back_ios_new_rounded,
                    onTap: () => context.go('/'),
                  ),
                  const Spacer(),
                  Text(
                    text['scanQrTitle'] ?? 'Scan QR to Pay',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  _IconBtn(
                    icon: _flashOn
                        ? Icons.flash_on_rounded
                        : Icons.flash_off_rounded,
                    onTap: _toggleFlash,
                  ),
                ],
              ),
            ),
          ),

          // Instruction + demo buttons at bottom
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: Text(
                        text['scanQrInstruction'] ??
                            'Align the QR code within the frame',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    _DemoButton(
                      label: text['simulateDynamic'] ??
                          'Simulate Dynamic QR (fixed amount)',
                      color: const Color(0xFF0079BF),
                      onTap: () =>
                          _navigateToPayment(QrPaymentData.testDynamic()),
                    ),
                    const SizedBox(height: 10),
                    _DemoButton(
                      label: text['simulateStatic'] ??
                          'Simulate Static QR (enter amount)',
                      color: const Color(0xFF0E9A33),
                      onTap: () =>
                          _navigateToPayment(QrPaymentData.testStatic()),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Custom painter ────────────────────────────────────────────────────────────

class _ScannerOverlayPainter extends CustomPainter {
  final double cutoutSize;
  final double scanProgress;

  const _ScannerOverlayPainter({
    required this.cutoutSize,
    required this.scanProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final left = cx - cutoutSize / 2;
    final top = cy - cutoutSize / 2;
    final right = cx + cutoutSize / 2;
    final bottom = cy + cutoutSize / 2;
    const r = 16.0;

    // Semi-transparent overlay with rounded-rect hole
    final overlayPaint = Paint()..color = Colors.black.withValues(alpha: 0.62);
    final holePath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(RRect.fromLTRBR(left, top, right, bottom, const Radius.circular(r)));
    holePath.fillType = PathFillType.evenOdd;
    canvas.drawPath(holePath, overlayPaint);

    // Corner brackets
    const bracketLen = 28.0;
    const bracketWidth = 3.5;
    final bracketPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = bracketWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Top-left
    canvas.drawLine(Offset(left + r, top), Offset(left + r + bracketLen, top), bracketPaint);
    canvas.drawLine(Offset(left, top + r), Offset(left, top + r + bracketLen), bracketPaint);
    // Top-right
    canvas.drawLine(Offset(right - r - bracketLen, top), Offset(right - r, top), bracketPaint);
    canvas.drawLine(Offset(right, top + r), Offset(right, top + r + bracketLen), bracketPaint);
    // Bottom-left
    canvas.drawLine(Offset(left + r, bottom), Offset(left + r + bracketLen, bottom), bracketPaint);
    canvas.drawLine(Offset(left, bottom - r - bracketLen), Offset(left, bottom - r), bracketPaint);
    // Bottom-right
    canvas.drawLine(Offset(right - r - bracketLen, bottom), Offset(right - r, bottom), bracketPaint);
    canvas.drawLine(Offset(right, bottom - r - bracketLen), Offset(right, bottom - r), bracketPaint);

    // Scan line
    final scanY = top + scanProgress * cutoutSize;
    final scanPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.transparent,
          const Color(0xFF0079BF).withValues(alpha: 0.8),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(left, scanY - 1, cutoutSize, 2));
    canvas.drawRect(Rect.fromLTWH(left, scanY - 1, cutoutSize, 2), scanPaint);
  }

  @override
  bool shouldRepaint(_ScannerOverlayPainter old) =>
      old.scanProgress != scanProgress;
}

// ── Helpers ───────────────────────────────────────────────────────────────────

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _IconBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.45),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}

class _DemoButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _DemoButton({
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        onPressed: onTap,
        style: TextButton.styleFrom(
          backgroundColor: color.withValues(alpha: 0.9),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
