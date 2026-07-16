import 'package:flutter_test/flutter_test.dart';
import 'package:zunga/insights/sms_parser.dart';

void main() {
  final parser = SmsParser();

  test('parses an MTN M-Money received SMS', () {
    final parsed = parser.parse(
      sender: 'M-Money',
      body:
          'You have received 25,000 RWF from Alexis K (*********517) on your mobile money account. '
          'Your new balance: 62,300 RWF. Fee: 0 RWF. Transaction Id: 18234567890.',
    );
    expect(parsed, isNotNull);
    expect(parsed!.incoming, isTrue);
    expect(parsed.amount, 25000);
    expect(parsed.counterparty, 'Alexis K');
    expect(parsed.balance, 62300);
    expect(parsed.fee, 0);
    expect(parsed.ref, '18234567890');
  });

  test('parses a sent/transferred SMS', () {
    final parsed = parser.parse(
      sender: 'M-Money',
      body:
          '12,500 RWF transferred to UWASE Marie Claire (250788412903) '
          'from 36521 at 2026-07-15 09:41:00. Fee was 100 RWF. New balance: 132,600 RWF.',
    );
    expect(parsed, isNotNull);
    expect(parsed!.incoming, isFalse);
    expect(parsed.amount, 12500);
    expect(parsed.counterparty, 'UWASE Marie Claire');
    expect(parsed.fee, 100);
  });

  test('ignores senders not on the allowlist', () {
    final parsed = parser.parse(
      sender: 'PROMO-4U',
      body: 'You have received 1,000,000 RWF! Click here to claim.',
    );
    expect(parsed, isNull, reason: 'never parse non-allowlisted senders');
  });

  test('returns null for non-transactional carrier messages', () {
    final parsed = parser.parse(
      sender: 'M-Money',
      body: 'Welcome to MoMo from MTN. Dial *182# to get started.',
    );
    expect(parsed, isNull);
  });
}
