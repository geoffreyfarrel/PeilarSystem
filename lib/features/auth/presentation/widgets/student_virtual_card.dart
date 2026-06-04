import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../landing/presentation/providers/language_provider.dart';

class StudentVirtualCard extends ConsumerWidget {
  final String studentId;
  final String name;
  final String major;

  const StudentVirtualCard({
    super.key,
    required this.studentId,
    required this.name,
    required this.major,
  });

  void _showModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: Colors.white,
      builder: (_) => _CardActionModal(
        onScanQr: () {
          Navigator.pop(context);
          context.go('/qr-scanner');
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final texts = ref.watch(appTextProvider);

    return GestureDetector(
      onTap: () => _showModal(context),
      child: AspectRatio(
        aspectRatio: 1.586,
        child: Card(
          elevation: 8,
          shadowColor: Colors.black26,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              Container(color: Colors.white),
              // Orange blob — top left
              Positioned(
                top: -24,
                left: -24,
                child: Container(
                  width: 130,
                  height: 120,
                  decoration: const BoxDecoration(
                    color: Color(0xFFEDA944),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(60),
                      bottomLeft: Radius.circular(50),
                      bottomRight: Radius.circular(90),
                    ),
                  ),
                ),
              ),
              // Blue blob — top right
              Positioned(
                top: -32,
                right: -18,
                child: Container(
                  width: 145,
                  height: 130,
                  decoration: const BoxDecoration(
                    color: Color(0xFF0079BF),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(90),
                      bottomLeft: Radius.circular(70),
                      topRight: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                ),
              ),
              // Pink blob — center left
              Positioned(
                top: 16,
                left: -36,
                child: Container(
                  width: 160,
                  height: 145,
                  decoration: const BoxDecoration(
                    color: Color(0xFFC6006E),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(50),
                      topRight: Radius.circular(95),
                      bottomLeft: Radius.circular(40),
                      bottomRight: Radius.circular(65),
                    ),
                  ),
                ),
              ),
              // Green blob — bottom right
              Positioned(
                bottom: -14,
                right: -14,
                child: Container(
                  width: 145,
                  height: 110,
                  decoration: const BoxDecoration(
                    color: Color(0xFF0E9A33),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(80),
                      topRight: Radius.circular(40),
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                ),
              ),
              // Card content
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Align(
                      alignment: Alignment.topRight,
                      child: const _EasyCardLogo(),
                    ),
                    const Spacer(),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              texts['easyCardTitle']!,
                              style: const TextStyle(
                                color: Colors.black87,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 1),
                            Text(
                              texts['adultCard']!,
                              style: const TextStyle(
                                color: Colors.black54,
                                fontSize: 9,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              studentId,
                              style: const TextStyle(
                                color: Colors.black87,
                                fontSize: 12,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1,
                              ),
                            ),
                            Text(
                              name,
                              style: const TextStyle(
                                color: Colors.black87,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              major,
                              style: const TextStyle(
                                color: Colors.black54,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EasyCardLogo extends ConsumerWidget {
  const _EasyCardLogo();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final texts = ref.watch(appTextProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 36,
          height: 26,
          child: CustomPaint(painter: _PinwheelPainter()),
        ),
        const SizedBox(height: 2),
        Text(
          texts['easyCardCompany']!,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 8,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
          ),
        ),
        Text(
          texts['easyCardCorpEn']!,
          style: const TextStyle(
            color: Colors.black54,
            fontSize: 7,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}

class _PinwheelPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width * 0.55;
    final cy = size.height * 0.45;
    final r = size.width * 0.4;

    _drawPetal(canvas, cx, cy, r, -80 * pi / 180, const Color(0xFFEDA944));
    _drawPetal(canvas, cx, cy, r, 40 * pi / 180, const Color(0xFF0079BF));
    _drawPetal(canvas, cx, cy, r, 160 * pi / 180, const Color(0xFF0E9A33));
  }

  void _drawPetal(
    Canvas canvas,
    double cx,
    double cy,
    double r,
    double angle,
    Color color,
  ) {
    final paint = Paint()..color = color;
    final tipX = cx + r * cos(angle);
    final tipY = cy + r * sin(angle);
    final perpAngle = angle + pi / 2;
    final halfWidth = r * 0.42;
    final ctrlDist = r * 0.6;

    final path = Path();
    path.moveTo(cx, cy);
    path.cubicTo(
      cx + halfWidth * cos(perpAngle),
      cy + halfWidth * sin(perpAngle),
      tipX + ctrlDist * cos(perpAngle + pi),
      tipY + ctrlDist * sin(perpAngle + pi),
      tipX,
      tipY,
    );
    path.cubicTo(
      tipX + ctrlDist * cos(perpAngle),
      tipY + ctrlDist * sin(perpAngle),
      cx - halfWidth * cos(perpAngle),
      cy - halfWidth * sin(perpAngle),
      cx,
      cy,
    );
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CardActionModal extends ConsumerWidget {
  final VoidCallback onScanQr;

  const _CardActionModal({required this.onScanQr});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final texts = ref.watch(appTextProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            texts['useVirtualCard']!,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: Color(0xFF2F2929),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            texts['chooseCardUsage']!,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
          ),
          const SizedBox(height: 28),
          Row(
            children: [
              Expanded(
                child: _ActionButton(
                  icon: Icons.qr_code_scanner,
                  label: texts['qrScanner']!,
                  color: const Color(0xFF0079BF),
                  onTap: onScanQr,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _ActionButton(
                  icon: Icons.nfc,
                  label: texts['nfc']!,
                  color: const Color(0xFF0E9A33),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 22),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.25), width: 1.5),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 34),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w800,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
