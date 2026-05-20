import 'dart:math';
import '../entities/qr_payment.dart';

/// Generates randomized mock QR payloads for demo and testing.
class QrMockGenerator {
  QrMockGenerator._();

  static final _rng = Random();

  // ── Dynamic QR (merchant-set fixed amount) ────────────────────────────────

  static const _dynamicMerchants = [
    ('FamilyMart', 'Convenience Store'),
    ('7-Eleven', 'Convenience Store'),
    ('McDonald\'s', 'Fast Food'),
    ('Starbucks', 'Café'),
    ('PX Mart', 'Supermarket'),
    ('Carrefour', 'Supermarket'),
    ('MOS Burger', 'Fast Food'),
    ('HiLife', 'Convenience Store'),
  ];

  static const _currencies = ['TWD', 'TWD', 'TWD', 'USD', 'CNY'];

  /// Returns a [QrPaymentData] with a random merchant and amount,
  /// plus the raw string that would be encoded in the QR image.
  static ({QrPaymentData data, String rawPayload}) createDynamic({
    String? merchant,
    String? category,
    double? amount,
    String? currency,
  }) {
    final pick = _dynamicMerchants[_rng.nextInt(_dynamicMerchants.length)];
    final m = merchant ?? pick.$1;
    final c = category ?? pick.$2;
    final amt = amount ?? _randomAmount();
    final cur = currency ?? _currencies[_rng.nextInt(_currencies.length)];
    final ref = _generateRef();

    final raw = 'PEILAR:$m:${amt % 1 == 0 ? amt.toInt() : amt.toStringAsFixed(2)}:$cur:$ref';

    final data = QrPaymentData(
      merchantName: m,
      merchantCategory: c,
      type: QrType.dynamic,
      fixedAmount: amt,
      currency: cur,
      reference: ref,
      rawValue: raw,
    );

    return (data: data, rawPayload: raw);
  }

  // ── Static QR (account-based, user enters amount) ─────────────────────────

  static const _staticMerchants = [
    ('Night Market Stall', 'Street Food'),
    ('TestStore Sanxia', 'Local Shop'),
    ('Green Tea Bakery', 'Bakery'),
    ('Uncle Chen Noodles', 'Restaurant'),
    ('Taipei Bike Repair', 'Services'),
    ('Sunday Market', 'Market'),
  ];

  /// Returns a [QrPaymentData] for a static (open-amount) QR,
  /// plus the raw account-encoded string.
  static ({QrPaymentData data, String rawPayload}) createStatic({
    String? merchant,
    String? category,
    String? accountId,
  }) {
    final pick = _staticMerchants[_rng.nextInt(_staticMerchants.length)];
    final m = merchant ?? pick.$1;
    final c = category ?? pick.$2;
    final acc = accountId ?? _generateAccountId();

    final raw = 'PEILAR:$m:$acc';

    final data = QrPaymentData(
      merchantName: m,
      merchantCategory: c,
      type: QrType.staticQr,
      rawValue: raw,
    );

    return (data: data, rawPayload: raw);
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  static double _randomAmount() {
    // Realistic retail amounts: 25–1500 TWD, rounded to 0 or .50
    final base = 25 + _rng.nextInt(1476);
    return _rng.nextBool() ? base.toDouble() : base + 0.5;
  }

  static String _generateRef() {
    final ts = DateTime.now().millisecondsSinceEpoch;
    final suffix = _rng.nextInt(9999).toString().padLeft(4, '0');
    return 'TXN$ts$suffix';
  }

  static String _generateAccountId() {
    final digits = List.generate(10, (_) => _rng.nextInt(10)).join();
    return 'ACC$digits';
  }
}
