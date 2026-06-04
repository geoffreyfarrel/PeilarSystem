import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../landing/presentation/providers/language_provider.dart';
import '../../domain/entities/qr_payment.dart';
import '../providers/payment_provider.dart';

class PaymentPage extends ConsumerWidget {
  const PaymentPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = ref.watch(appTextProvider);
    final payment = ref.watch(paymentProvider);
    final notifier = ref.read(paymentProvider.notifier);

    final qr = payment.qrData;
    if (qr == null) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => context.go('/qr-scanner'),
      );
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    ref.listen(paymentProvider, (_, next) {
      if (next.status == PaymentStatus.success ||
          next.status == PaymentStatus.failed) {
        context.go('/payment-result');
      }
    });

    final isProcessing = payment.status == PaymentStatus.processing;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: Column(
        children: [
          _Header(qr: qr, text: text),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  _AmountCard(qr: qr, payment: payment, text: text),
                  if (!qr.isDynamic) ...[
                    const SizedBox(height: 16),
                    _VirtualNumpad(notifier: notifier),
                  ],
                  const SizedBox(height: 24),
                  _PayButton(
                    isProcessing: isProcessing,
                    canPay: payment.amount > 0,
                    label: isProcessing
                        ? (text['processing'] ?? 'Processing…')
                        : (text['confirmPay'] ?? 'Confirm Payment'),
                    onTap: isProcessing ? null : notifier.processPayment,
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final QrPaymentData qr;
  final Map<String, String> text;

  const _Header({required this.qr, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0079BF), Color(0xFF0079BF)],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
          child: Column(
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () => context.go('/qr-scanner'),
                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    text['paymentTitle'] ?? 'Confirm Payment',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  const SizedBox(width: 20),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.store_rounded,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                qr.merchantName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _QrTypeBadge(isDynamic: qr.isDynamic, text: text),
                  const SizedBox(width: 8),
                  Text(
                    qr.merchantCategory,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.75),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QrTypeBadge extends StatelessWidget {
  final bool isDynamic;
  final Map<String, String> text;

  const _QrTypeBadge({required this.isDynamic, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isDynamic
            ? const Color(0xFFEDA944).withValues(alpha: 0.9)
            : const Color(0xFF0E9A33).withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        isDynamic
            ? (text['dynamicQrBadge'] ?? 'Dynamic QR')
            : (text['staticQrBadge'] ?? 'Static QR'),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

// ── Amount card ───────────────────────────────────────────────────────────────

class _AmountCard extends StatelessWidget {
  final QrPaymentData qr;
  final PaymentState payment;
  final Map<String, String> text;

  const _AmountCard({
    required this.qr,
    required this.payment,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final hasInput = payment.amountInput.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              text['paymentAmount'] ?? 'Payment Amount',
              style: const TextStyle(
                color: Color(0xFF646363),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              hasInput ? 'NT\$ ${payment.amountInput}' : (text['enterAmount'] ?? 'Enter Amount'),
              style: TextStyle(
                color: hasInput ? const Color(0xFF2F2929) : const Color(0xFFD1D5DB),
                fontSize: 40,
                fontWeight: FontWeight.w900,
                letterSpacing: -1,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: qr.isDynamic
                    ? const Color(0xFFFFF3DC)
                    : const Color(0xFFE5F5EB),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(
                    qr.isDynamic ? Icons.lock_rounded : Icons.edit_rounded,
                    size: 15,
                    color: qr.isDynamic
                        ? const Color(0xFFEDA944)
                        : const Color(0xFF0E9A33),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      qr.isDynamic
                          ? (text['dynamicQrLocked'] ??
                              'Amount set by merchant, cannot be changed')
                          : (text['staticQrEnter'] ??
                              'Please enter the payment amount'),
                      style: TextStyle(
                        color: qr.isDynamic
                            ? const Color(0xFFEDA944)
                            : const Color(0xFF0E9A33),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Virtual numpad ────────────────────────────────────────────────────────────

class _VirtualNumpad extends StatelessWidget {
  final PaymentNotifier notifier;

  const _VirtualNumpad({required this.notifier});

  static const _rows = [
    ['1', '2', '3'],
    ['4', '5', '6'],
    ['7', '8', '9'],
    ['.', '0', '⌫'],
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: _rows.map((row) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: row.map((key) {
                final isDelete = key == '⌫';
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: _NumKey(
                      label: key,
                      isDelete: isDelete,
                      onTap: isDelete
                          ? notifier.deleteLast
                          : () => notifier.appendDigit(key),
                    ),
                  ),
                );
              }).toList(),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _NumKey extends StatelessWidget {
  final String label;
  final bool isDelete;
  final VoidCallback onTap;

  const _NumKey({
    required this.label,
    required this.isDelete,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          color: isDelete ? const Color(0xFFFCE4F0) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: isDelete
              ? const Icon(
                  Icons.backspace_outlined,
                  color: Color(0xFFC6006E),
                  size: 22,
                )
              : Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFF2F2929),
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ),
    );
  }
}

// ── Pay button ────────────────────────────────────────────────────────────────

class _PayButton extends StatelessWidget {
  final bool isProcessing;
  final bool canPay;
  final String label;
  final VoidCallback? onTap;

  const _PayButton({
    required this.isProcessing,
    required this.canPay,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            gradient: canPay && !isProcessing
                ? const LinearGradient(
                    colors: [Color(0xFF0E9A33), Color(0xFF0E9A33)],
                  )
                : null,
            color: !canPay || isProcessing ? const Color(0xFFE3E3E3) : null,
            borderRadius: BorderRadius.circular(16),
            boxShadow: canPay && !isProcessing
                ? [
                    BoxShadow(
                      color: const Color(0xFF0E9A33).withValues(alpha: 0.35),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : null,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: canPay ? onTap : null,
              borderRadius: BorderRadius.circular(16),
              child: Center(
                child: isProcessing
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.lock_rounded,
                            color: canPay
                                ? Colors.white
                                : const Color(0xFF646363),
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            label,
                            style: TextStyle(
                              color: canPay
                                  ? Colors.white
                                  : const Color(0xFF646363),
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
