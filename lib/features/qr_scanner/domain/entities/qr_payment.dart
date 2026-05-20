enum QrType { dynamic, staticQr }

class QrPaymentData {
  final String merchantName;
  final String merchantCategory;
  final QrType type;
  final double? fixedAmount;
  final String currency;
  final String? reference;
  final String rawValue;

  const QrPaymentData({
    required this.merchantName,
    this.merchantCategory = 'General',
    required this.type,
    this.fixedAmount,
    this.currency = 'TWD',
    this.reference,
    required this.rawValue,
  });

  bool get isDynamic => type == QrType.dynamic;

  // Parses: PEILAR:<merchant>:<amount>:<currency>:<ref> → dynamic
  //         PEILAR:<merchant>:<account>             → static
  //         anything else                           → static
  factory QrPaymentData.parse(String raw) {
    if (raw.startsWith('PEILAR:')) {
      final parts = raw.split(':');
      if (parts.length >= 3) {
        final merchant = parts[1];
        final maybeAmount = double.tryParse(parts[2]);
        if (maybeAmount != null) {
          return QrPaymentData(
            merchantName: merchant,
            merchantCategory: 'Retail',
            type: QrType.dynamic,
            fixedAmount: maybeAmount,
            currency: parts.length > 3 ? parts[3] : 'TWD',
            reference: parts.length > 4 ? parts[4] : null,
            rawValue: raw,
          );
        }
      }
    }
    return QrPaymentData(
      merchantName: _extractMerchant(raw),
      merchantCategory: 'General',
      type: QrType.staticQr,
      rawValue: raw,
    );
  }

  static String _extractMerchant(String raw) {
    if (raw.startsWith('PEILAR:')) {
      final parts = raw.split(':');
      return parts.length > 1 ? parts[1] : 'Unknown';
    }
    if (raw.startsWith('http')) return 'Web Merchant';
    if (raw.length > 24) return '${raw.substring(0, 24)}…';
    return raw.isEmpty ? 'Unknown Merchant' : raw;
  }

  static QrPaymentData testDynamic() => const QrPaymentData(
        merchantName: 'FamilyMart',
        merchantCategory: 'Convenience Store',
        type: QrType.dynamic,
        fixedAmount: 150.0,
        currency: 'TWD',
        reference: 'TXN202605210001',
        rawValue: 'PEILAR:FamilyMart:150:TWD:TXN202605210001',
      );

  static QrPaymentData testStatic() => const QrPaymentData(
        merchantName: 'TestStore Sanxia',
        merchantCategory: 'Local Shop',
        type: QrType.staticQr,
        rawValue: 'PEILAR:TestStore:ACC1234567890',
      );
}
