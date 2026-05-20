import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/qr_payment.dart';

enum PaymentStatus { idle, processing, success, failed }

class PaymentState {
  final PaymentStatus status;
  final QrPaymentData? qrData;
  final double amount;
  final String amountInput;
  final String? errorMessage;
  final String? transactionRef;

  const PaymentState({
    this.status = PaymentStatus.idle,
    this.qrData,
    this.amount = 0,
    this.amountInput = '',
    this.errorMessage,
    this.transactionRef,
  });

  PaymentState copyWith({
    PaymentStatus? status,
    QrPaymentData? qrData,
    double? amount,
    String? amountInput,
    String? errorMessage,
    String? transactionRef,
  }) {
    return PaymentState(
      status: status ?? this.status,
      qrData: qrData ?? this.qrData,
      amount: amount ?? this.amount,
      amountInput: amountInput ?? this.amountInput,
      errorMessage: errorMessage,
      transactionRef: transactionRef ?? this.transactionRef,
    );
  }
}

class PaymentNotifier extends Notifier<PaymentState> {
  @override
  PaymentState build() => const PaymentState();

  void loadQrData(QrPaymentData data) {
    state = PaymentState(
      qrData: data,
      amount: data.fixedAmount ?? 0,
      amountInput: data.fixedAmount != null
          ? data.fixedAmount! % 1 == 0
              ? data.fixedAmount!.toInt().toString()
              : data.fixedAmount!.toStringAsFixed(2)
          : '',
    );
  }

  void appendDigit(String digit) {
    if (state.qrData?.isDynamic == true) return;
    var current = state.amountInput;

    if (digit == '.' && current.contains('.')) return;
    if (digit == '.' && current.isEmpty) current = '0';
    if (current == '0' && digit != '.') current = '';
    if (current.contains('.') && current.split('.')[1].length >= 2) return;

    final next = current + digit;
    final parsed = double.tryParse(next) ?? 0;
    state = state.copyWith(amountInput: next, amount: parsed);
  }

  void deleteLast() {
    if (state.qrData?.isDynamic == true) return;
    if (state.amountInput.isEmpty) return;
    final next = state.amountInput.substring(0, state.amountInput.length - 1);
    state = state.copyWith(
      amountInput: next,
      amount: double.tryParse(next) ?? 0,
    );
  }

  void clearAmount() {
    if (state.qrData?.isDynamic == true) return;
    state = state.copyWith(amountInput: '', amount: 0);
  }

  Future<void> processPayment() async {
    if (state.amount <= 0) return;
    state = state.copyWith(status: PaymentStatus.processing);
    await Future.delayed(const Duration(milliseconds: 2200));
    final success = Random().nextInt(10) < 8;
    final ref = 'TXN${DateTime.now().millisecondsSinceEpoch}';
    if (success) {
      state = state.copyWith(
        status: PaymentStatus.success,
        transactionRef: ref,
        errorMessage: null,
      );
    } else {
      state = state.copyWith(
        status: PaymentStatus.failed,
        errorMessage: 'Transaction declined by bank.',
        transactionRef: null,
      );
    }
  }

  void reset() => state = const PaymentState();
}

final paymentProvider = NotifierProvider<PaymentNotifier, PaymentState>(
  PaymentNotifier.new,
);
