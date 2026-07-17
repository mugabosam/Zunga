import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// The anti-Faranga rule (§2.1 of the execution prompt): a transaction
/// is NEVER "made" at button-press. It walks a strict lifecycle and
/// appears in history, totals and lifetime stats only at [confirmed].
/// Cancelling the carrier PIN dialog must never leave a phantom record.
enum TxStatus { initiated, awaitingPin, pendingConfirmation, confirmed, failed, cancelled }

class TxRecord {
  const TxRecord({
    required this.id,
    required this.msisdn,
    this.counterpartyName,
    required this.amount,
    required this.network,
    required this.status,
    required this.createdAt,
    this.reference,
  });

  final String id;
  final String msisdn;

  /// Resolved via the name ladder — carrier confirm step, SMS, contacts,
  /// cache. Never rendered as "Unknown": absent names show the masked
  /// number, and the cache backfills them permanently once known.
  final String? counterpartyName;
  final int amount;
  final String network;
  final TxStatus status;
  final DateTime createdAt;
  final String? reference;

  TxRecord copyWith({TxStatus? status, String? counterpartyName, String? reference}) {
    return TxRecord(
      id: id,
      msisdn: msisdn,
      counterpartyName: counterpartyName ?? this.counterpartyName,
      amount: amount,
      network: network,
      status: status ?? this.status,
      createdAt: createdAt,
      reference: reference ?? this.reference,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'msisdn': msisdn,
        'counterpartyName': counterpartyName,
        'amount': amount,
        'network': network,
        'status': status.name,
        'createdAt': createdAt.toIso8601String(),
        'reference': reference,
      };

  factory TxRecord.fromMap(Map<dynamic, dynamic> map) => TxRecord(
        id: map['id'] as String,
        msisdn: map['msisdn'] as String,
        counterpartyName: map['counterpartyName'] as String?,
        amount: map['amount'] as int,
        network: map['network'] as String? ?? '',
        status: TxStatus.values.firstWhere(
          (s) => s.name == map['status'],
          orElse: () => TxStatus.pendingConfirmation,
        ),
        createdAt:
            DateTime.tryParse(map['createdAt'] as String? ?? '') ?? DateTime.now(),
        reference: map['reference'] as String?,
      );
}

/// History semantics:
///  - [confirmedOnly] feeds totals, insights and lifetime stats;
///  - [awaitingResolution] renders with a grey "unconfirmed" badge and a
///    verify action — honest uncertainty, never fake certainty;
///  - cancelled/failed are hidden from history by default.
class TransactionsNotifier extends Notifier<List<TxRecord>> {
  static const _boxName = 'transactions';

  @override
  List<TxRecord> build() {
    _load();
    return const [];
  }

  Future<void> _load() async {
    final box = await Hive.openBox<Map>(_boxName);
    state = _sorted(box.values.map(TxRecord.fromMap).toList());
  }

  Future<TxRecord> record(TxRecord tx) async {
    final box = await Hive.openBox<Map>(_boxName);
    await box.put(tx.id, tx.toMap());
    state = _sorted([...state.where((t) => t.id != tx.id), tx]);
    return tx;
  }

  Future<void> setStatus(String id, TxStatus status) async {
    final box = await Hive.openBox<Map>(_boxName);
    final existing = state.where((t) => t.id == id).toList();
    if (existing.isEmpty) return;
    final updated = existing.first.copyWith(status: status);
    await box.put(id, updated.toMap());
    state = _sorted([...state.where((t) => t.id != id), updated]);
  }

  Future<void> resolveName(String msisdn, String name) async {
    final box = await Hive.openBox<Map>(_boxName);
    final updated = <TxRecord>[];
    for (final t in state) {
      if (t.msisdn == msisdn && t.counterpartyName == null) {
        final u = t.copyWith(counterpartyName: name);
        await box.put(u.id, u.toMap());
        updated.add(u);
      } else {
        updated.add(t);
      }
    }
    state = _sorted(updated);
  }

  Future<void> wipe() async {
    final box = await Hive.openBox<Map>(_boxName);
    await box.clear();
    state = const [];
  }

  List<TxRecord> _sorted(List<TxRecord> list) {
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return List.unmodifiable(list);
  }
}

final transactionsProvider =
    NotifierProvider<TransactionsNotifier, List<TxRecord>>(TransactionsNotifier.new);

/// Only confirmed transactions exist as far as money math is concerned.
final confirmedTxProvider = Provider<List<TxRecord>>((ref) {
  return ref
      .watch(transactionsProvider)
      .where((t) => t.status == TxStatus.confirmed)
      .toList();
});

/// Sent but not yet proven by USSD success string or carrier SMS.
final awaitingResolutionProvider = Provider<List<TxRecord>>((ref) {
  return ref
      .watch(transactionsProvider)
      .where((t) =>
          t.status == TxStatus.awaitingPin ||
          t.status == TxStatus.pendingConfirmation)
      .toList();
});

/// Lifetime stats — confirmed-only, per the execution prompt.
final lifetimeStatsProvider = Provider<({int sent, int count})>((ref) {
  final confirmed = ref.watch(confirmedTxProvider);
  final sent = confirmed.fold<int>(0, (sum, t) => sum + t.amount);
  return (sent: sent, count: confirmed.length);
});
