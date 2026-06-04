import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../landing/presentation/providers/language_provider.dart';
import '../providers/payment_provider.dart';

class PaymentResultPage extends ConsumerWidget {
  const PaymentResultPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = ref.watch(appTextProvider);
    final payment = ref.watch(paymentProvider);
    final notifier = ref.read(paymentProvider.notifier);

    final isSuccess = payment.status == PaymentStatus.success;
    final qr = payment.qrData;
    final amount = payment.amount;
    final now = DateTime.now();
    final timeStr =
        '${now.year}-${_pad(now.month)}-${_pad(now.day)} '
        '${_pad(now.hour)}:${_pad(now.minute)}:${_pad(now.second)}';

    return PopScope(
      canPop: false,
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: isSuccess
                  ? [const Color(0xFFE5F5EB), const Color(0xFFE5F5EB)]
                  : [const Color(0xFFFCE4F0), const Color(0xFFFCE4F0)],
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                child: Column(
                  children: [
                    // Status icon
                    _StatusIcon(isSuccess: isSuccess),
                    const SizedBox(height: 20),

                    // Title
                    Text(
                      isSuccess
                          ? (text['paymentSuccess'] ?? 'Payment Successful')
                          : (text['paymentFailed'] ?? 'Payment Failed'),
                      style: TextStyle(
                        color: isSuccess
                            ? const Color(0xFF0E9A33)
                            : const Color(0xFFC6006E),
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isSuccess
                          ? (text['paymentSuccessDesc'] ??
                              'Your payment is complete. Thank you!')
                          : (text['paymentFailedDesc'] ??
                              'Transaction declined. Please try again.'),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isSuccess
                            ? const Color(0xFF0E9A33)
                            : const Color(0xFFC6006E),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Shadcn-style detail card
                    _DetailCard(
                      isSuccess: isSuccess,
                      text: text,
                      merchantName: qr?.merchantName ?? '—',
                      amount: amount,
                      txRef: payment.transactionRef,
                      timeStr: timeStr,
                    ),
                    const SizedBox(height: 32),

                    // Action buttons
                    if (isSuccess)
                      _ActionButton(
                        label: text['done'] ?? 'Done',
                        icon: Icons.check_circle_outline_rounded,
                        color: const Color(0xFF0E9A33),
                        onTap: () {
                          notifier.reset();
                          context.go('/');
                        },
                      )
                    else ...[
                      _ActionButton(
                        label: text['tryAgain'] ?? 'Try Again',
                        icon: Icons.refresh_rounded,
                        color: const Color(0xFFC6006E),
                        onTap: () {
                          notifier.reset();
                          context.go('/qr-scanner');
                        },
                      ),
                      const SizedBox(height: 12),
                      _ActionButton(
                        label: text['backToHome'] ?? 'Back to Home',
                        icon: Icons.home_rounded,
                        color: const Color(0xFF646363),
                        outlined: true,
                        onTap: () {
                          notifier.reset();
                          context.go('/');
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  static String _pad(int n) => n.toString().padLeft(2, '0');
}

// ── Status icon ───────────────────────────────────────────────────────────────

class _StatusIcon extends StatefulWidget {
  final bool isSuccess;
  const _StatusIcon({required this.isSuccess});

  @override
  State<_StatusIcon> createState() => _StatusIconState();
}

class _StatusIconState extends State<_StatusIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scale = CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut);
    _opacity = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isSuccess = widget.isSuccess;
    final bg = isSuccess ? const Color(0xFF0E9A33) : const Color(0xFFC6006E);
    final ring = isSuccess ? const Color(0xFFE5F5EB) : const Color(0xFFFCE4F0);

    return FadeTransition(
      opacity: _opacity,
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: ring,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: bg,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: bg.withValues(alpha: 0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Icon(
                isSuccess
                    ? Icons.check_rounded
                    : Icons.close_rounded,
                color: Colors.white,
                size: 40,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Detail card ───────────────────────────────────────────────────────────────

class _DetailCard extends StatelessWidget {
  final bool isSuccess;
  final Map<String, String> text;
  final String merchantName;
  final double amount;
  final String? txRef;
  final String timeStr;

  const _DetailCard({
    required this.isSuccess,
    required this.text,
    required this.merchantName,
    required this.amount,
    required this.txRef,
    required this.timeStr,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = isSuccess
        ? const Color(0xFFDDE7D7)
        : const Color(0xFFFCE4F0);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _DetailRow(
            label: text['transactionAmount'] ?? 'Amount',
            value: 'NT\$ ${amount % 1 == 0 ? amount.toInt() : amount.toStringAsFixed(2)}',
            valueStyle: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: Color(0xFF2F2929),
            ),
          ),
          const _Divider(),
          _DetailRow(
            label: text['transactionMerchant'] ?? 'Merchant',
            value: merchantName,
          ),
          if (txRef != null) ...[
            const _Divider(),
            _DetailRow(
              label: text['transactionRef'] ?? 'Transaction Ref',
              value: txRef!,
              mono: true,
            ),
          ],
          const _Divider(),
          _DetailRow(
            label: text['transactionTime'] ?? 'Time',
            value: timeStr,
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final TextStyle? valueStyle;
  final bool mono;

  const _DetailRow({
    required this.label,
    required this.value,
    this.valueStyle,
    this.mono = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF646363),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: valueStyle ??
                  TextStyle(
                    color: const Color(0xFF2F2929),
                    fontSize: mono ? 11 : 14,
                    fontWeight: FontWeight.w600,
                    fontFamily: mono ? 'monospace' : null,
                    letterSpacing: mono ? 0.5 : 0,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return const Divider(
      height: 1,
      thickness: 1,
      color: Color(0xFFF7F7F7),
    );
  }
}

// ── Action button ─────────────────────────────────────────────────────────────

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool outlined;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
    this.outlined = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: outlined
          ? OutlinedButton.icon(
              onPressed: onTap,
              icon: Icon(icon, size: 18),
              label: Text(label),
              style: OutlinedButton.styleFrom(
                foregroundColor: color,
                side: BorderSide(color: color.withValues(alpha: 0.4)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                textStyle: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            )
          : ElevatedButton.icon(
              onPressed: onTap,
              icon: Icon(icon, size: 18, color: Colors.white),
              label: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                shadowColor: color.withValues(alpha: 0.3),
              ),
            ),
    );
  }
}
