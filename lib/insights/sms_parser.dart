/// On-device SMS parser (§3.4) — insights without servers.
///
/// Reads ONLY sender IDs on this allowlist. Raw SMS text never leaves
/// the device; parsed transactions land in encrypted Hive and power the
/// activity feed, weekly insights, merchant mode, and reconciliation of
/// USSD sessions (a send is only "successful" once the confirming SMS
/// arrives or the USSD success string matched).
library;

const smsSenderAllowlist = {
  'M-Money', // MTN MoMo
  'AirtelMoney', // Airtel Money
  // Bank sender IDs are added per bank during Stage 3 field verification.
};

class ParsedSms {
  const ParsedSms({
    required this.amount,
    required this.incoming,
    this.counterparty,
    this.fee,
    this.balance,
    this.ref,
  });

  final int amount;
  final bool incoming;
  final String? counterparty;
  final int? fee;
  final int? balance;
  final String? ref;
}

class SmsParser {
  /// MTN M-Money style: "You have received 25,000 RWF from Alexis K.
  /// (*********517)... Your new balance: 62,300 RWF. Fee: 0 RWF.
  /// Transaction Id: 1234567890."
  static final _received = RegExp(
    r'(?:received|wakiriye|reçu)\s+([\d,\.]+)\s*RWF\s+(?:from|kuva kuri|de)\s+([^(.]+)',
    caseSensitive: false,
  );

  /// "12,500 RWF transferred to UWASE Marie Claire ... Fee was 100 RWF."
  static final _sent = RegExp(
    r'([\d,\.]+)\s*RWF\s+(?:transferred|sent|paid|yoherejwe|wishyuye|transféré|payé)\s+(?:to|kuri|à)?\s*([^(.]+)?',
    caseSensitive: false,
  );

  static final _fee = RegExp(r'fee(?:\s+was)?\s*:?\s*([\d,\.]+)\s*RWF', caseSensitive: false);
  static final _balance = RegExp(r'balance\s*:?\s*([\d,\.]+)\s*RWF', caseSensitive: false);
  static final _ref = RegExp(r'(?:transaction\s*id|ref(?:erence)?)\s*:?\s*([A-Za-z0-9\-]+)', caseSensitive: false);

  /// Returns null when the sender is not allowlisted or no pattern matches.
  ParsedSms? parse({required String sender, required String body}) {
    if (!smsSenderAllowlist.contains(sender)) return null;

    final received = _received.firstMatch(body);
    final sent = received == null ? _sent.firstMatch(body) : null;
    final match = received ?? sent;
    if (match == null) return null;

    final amount = _num(match.group(1)!);
    if (amount == null) return null;

    return ParsedSms(
      amount: amount,
      incoming: received != null,
      counterparty: match.group(2)?.trim(),
      fee: _num(_fee.firstMatch(body)?.group(1)),
      balance: _num(_balance.firstMatch(body)?.group(1)),
      ref: _ref.firstMatch(body)?.group(1),
    );
  }

  int? _num(String? raw) {
    if (raw == null) return null;
    return int.tryParse(raw.replaceAll(',', '').split('.').first);
  }
}
