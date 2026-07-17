import 'package:flutter_test/flutter_test.dart';
import 'package:zunga/core/data/transactions.dart';

void main() {
  group('Transaction lifecycle (§2.1 — no phantoms)', () {
    final base = TxRecord(
      id: 't1',
      msisdn: '0788412903',
      counterpartyName: null,
      amount: 5000,
      network: 'MTN',
      status: TxStatus.awaitingPin,
      createdAt: DateTime(2026, 7, 18, 9, 0),
    );

    test('a send starts as awaiting_pin, never confirmed', () {
      expect(base.status, TxStatus.awaitingPin);
    });

    test('status walk: awaiting_pin → pending_confirmation → confirmed', () {
      final pending = base.copyWith(status: TxStatus.pendingConfirmation);
      final confirmed = pending.copyWith(status: TxStatus.confirmed);
      expect(pending.status, TxStatus.pendingConfirmation);
      expect(confirmed.status, TxStatus.confirmed);
      expect(confirmed.amount, 5000, reason: 'amount is immutable through the walk');
    });

    test('only confirmed transactions count toward totals', () {
      final ledger = [
        base.copyWith(status: TxStatus.confirmed),
        base.copyWith(status: TxStatus.pendingConfirmation),
        base.copyWith(status: TxStatus.cancelled),
        base.copyWith(status: TxStatus.failed),
      ];
      final total = ledger
          .where((t) => t.status == TxStatus.confirmed)
          .fold<int>(0, (sum, t) => sum + t.amount);
      expect(total, 5000,
          reason: 'pending, cancelled and failed must never inflate totals');
    });

    test('serialization roundtrip preserves the lifecycle state', () {
      final tx = base.copyWith(
          status: TxStatus.pendingConfirmation, counterpartyName: 'Alexis K.');
      final restored = TxRecord.fromMap(tx.toMap());
      expect(restored.status, TxStatus.pendingConfirmation);
      expect(restored.counterpartyName, 'Alexis K.');
      expect(restored.msisdn, '0788412903');
      expect(restored.createdAt, tx.createdAt);
    });

    test('unknown status strings degrade to pending, not confirmed', () {
      final map = base.toMap()..['status'] = 'exotic_future_state';
      expect(TxRecord.fromMap(map).status, TxStatus.pendingConfirmation,
          reason: 'never fake certainty on corrupt data');
    });
  });
}
