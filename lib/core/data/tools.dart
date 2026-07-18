import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Money tools — split a bill, ikimina rounds, merchant profile.
/// Everything lives on-device in Hive; group sync arrives with the
/// backend phase. No sample data: screens start empty.

// ---------------------------------------------------------------- split

class SplitParticipant {
  const SplitParticipant({
    required this.msisdn,
    this.name,
    required this.share,
    this.paid = false,
  });

  final String msisdn;
  final String? name;
  final int share;
  final bool paid;

  SplitParticipant copyWith({bool? paid}) => SplitParticipant(
        msisdn: msisdn,
        name: name,
        share: share,
        paid: paid ?? this.paid,
      );

  Map<String, dynamic> toMap() =>
      {'msisdn': msisdn, 'name': name, 'share': share, 'paid': paid};

  factory SplitParticipant.fromMap(Map<dynamic, dynamic> m) => SplitParticipant(
        msisdn: m['msisdn'] as String,
        name: m['name'] as String?,
        share: m['share'] as int,
        paid: m['paid'] as bool? ?? false,
      );

  String get initials {
    final n = name;
    if (n == null || n.trim().isEmpty) return '··';
    return n
        .trim()
        .split(RegExp(r'\s+'))
        .take(2)
        .map((w) => w[0].toUpperCase())
        .join();
  }
}

class SplitRequest {
  const SplitRequest({
    required this.id,
    required this.title,
    required this.total,
    required this.participants,
    required this.createdAt,
  });

  final String id;
  final String title;
  final int total;
  final List<SplitParticipant> participants;
  final DateTime createdAt;

  int get collected =>
      participants.where((p) => p.paid).fold(0, (sum, p) => sum + p.share);

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'total': total,
        'participants': participants.map((p) => p.toMap()).toList(),
        'createdAt': createdAt.toIso8601String(),
      };

  factory SplitRequest.fromMap(Map<dynamic, dynamic> m) => SplitRequest(
        id: m['id'] as String,
        title: m['title'] as String,
        total: m['total'] as int,
        participants: (m['participants'] as List)
            .map((p) => SplitParticipant.fromMap(p as Map))
            .toList(),
        createdAt:
            DateTime.tryParse(m['createdAt'] as String? ?? '') ?? DateTime.now(),
      );
}

/// Equal division with the remainder spread over the first shares so the
/// total always adds up exactly.
List<int> equalShares(int total, int people) {
  if (people <= 0) return const [];
  final base = total ~/ people;
  final remainder = total % people;
  return [for (var i = 0; i < people; i++) base + (i < remainder ? 1 : 0)];
}

class SplitsNotifier extends Notifier<List<SplitRequest>> {
  static const _boxName = 'splits';

  @override
  List<SplitRequest> build() {
    _load();
    return const [];
  }

  Future<void> _load() async {
    final box = await Hive.openBox<Map>(_boxName);
    state = _sorted(box.values.map(SplitRequest.fromMap).toList());
  }

  Future<void> create(SplitRequest split) async {
    final box = await Hive.openBox<Map>(_boxName);
    await box.put(split.id, split.toMap());
    state = _sorted([...state, split]);
  }

  Future<void> togglePaid(String splitId, String msisdn) async {
    final box = await Hive.openBox<Map>(_boxName);
    state = _sorted([
      for (final s in state)
        if (s.id == splitId)
          SplitRequest(
            id: s.id,
            title: s.title,
            total: s.total,
            participants: [
              for (final p in s.participants)
                p.msisdn == msisdn ? p.copyWith(paid: !p.paid) : p,
            ],
            createdAt: s.createdAt,
          )
        else
          s,
    ]);
    final updated = state.firstWhere((s) => s.id == splitId);
    await box.put(splitId, updated.toMap());
  }

  Future<void> remove(String splitId) async {
    final box = await Hive.openBox<Map>(_boxName);
    await box.delete(splitId);
    state = _sorted(state.where((s) => s.id != splitId).toList());
  }

  List<SplitRequest> _sorted(List<SplitRequest> list) {
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return List.unmodifiable(list);
  }
}

final splitsProvider =
    NotifierProvider<SplitsNotifier, List<SplitRequest>>(SplitsNotifier.new);

// -------------------------------------------------------------- ikimina

class IkiminaMember {
  const IkiminaMember({required this.name, this.msisdn, this.paid = false});

  final String name;
  final String? msisdn;

  /// Paid the current round's contribution.
  final bool paid;

  IkiminaMember copyWith({bool? paid}) =>
      IkiminaMember(name: name, msisdn: msisdn, paid: paid ?? this.paid);

  Map<String, dynamic> toMap() =>
      {'name': name, 'msisdn': msisdn, 'paid': paid};

  factory IkiminaMember.fromMap(Map<dynamic, dynamic> m) => IkiminaMember(
        name: m['name'] as String,
        msisdn: m['msisdn'] as String?,
        paid: m['paid'] as bool? ?? false,
      );

  String get initials => name
      .trim()
      .split(RegExp(r'\s+'))
      .take(2)
      .map((w) => w[0].toUpperCase())
      .join();
}

class IkiminaGroup {
  const IkiminaGroup({
    required this.id,
    required this.name,
    required this.contribution,
    required this.members,
    this.round = 1,
    this.receiverIndex = 0,
  });

  final String id;
  final String name;

  /// Per-member contribution each round, RWF.
  final int contribution;
  final List<IkiminaMember> members;
  final int round;

  /// Whose turn to receive this round (rotates each round).
  final int receiverIndex;

  int get pot => members.where((m) => m.paid).length * contribution;
  int get paidCount => members.where((m) => m.paid).length;
  IkiminaMember? get receiver =>
      members.isEmpty ? null : members[receiverIndex % members.length];

  IkiminaGroup copyWith({
    List<IkiminaMember>? members,
    int? round,
    int? receiverIndex,
  }) {
    return IkiminaGroup(
      id: id,
      name: name,
      contribution: contribution,
      members: members ?? this.members,
      round: round ?? this.round,
      receiverIndex: receiverIndex ?? this.receiverIndex,
    );
  }

  /// Closes the round: everyone unpaid again, next member receives.
  IkiminaGroup nextRound() => copyWith(
        members: [for (final m in members) m.copyWith(paid: false)],
        round: round + 1,
        receiverIndex: members.isEmpty ? 0 : (receiverIndex + 1) % members.length,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'contribution': contribution,
        'members': members.map((m) => m.toMap()).toList(),
        'round': round,
        'receiverIndex': receiverIndex,
      };

  factory IkiminaGroup.fromMap(Map<dynamic, dynamic> m) => IkiminaGroup(
        id: m['id'] as String,
        name: m['name'] as String,
        contribution: m['contribution'] as int,
        members: (m['members'] as List)
            .map((x) => IkiminaMember.fromMap(x as Map))
            .toList(),
        round: m['round'] as int? ?? 1,
        receiverIndex: m['receiverIndex'] as int? ?? 0,
      );
}

class IkiminaNotifier extends Notifier<List<IkiminaGroup>> {
  static const _boxName = 'ikimina';

  @override
  List<IkiminaGroup> build() {
    _load();
    return const [];
  }

  Future<void> _load() async {
    final box = await Hive.openBox<Map>(_boxName);
    state = List.unmodifiable(box.values.map(IkiminaGroup.fromMap));
  }

  Future<void> create(IkiminaGroup group) async {
    final box = await Hive.openBox<Map>(_boxName);
    await box.put(group.id, group.toMap());
    state = List.unmodifiable([...state, group]);
  }

  Future<void> update(IkiminaGroup group) async {
    final box = await Hive.openBox<Map>(_boxName);
    await box.put(group.id, group.toMap());
    state = List.unmodifiable(
        [for (final g in state) g.id == group.id ? group : g]);
  }

  Future<void> remove(String id) async {
    final box = await Hive.openBox<Map>(_boxName);
    await box.delete(id);
    state = List.unmodifiable(state.where((g) => g.id != id));
  }
}

final ikiminaProvider =
    NotifierProvider<IkiminaNotifier, List<IkiminaGroup>>(IkiminaNotifier.new);

// ------------------------------------------------------------- merchant

class MerchantProfile {
  const MerchantProfile({required this.businessName, required this.momoPayCode});

  final String businessName;
  final String momoPayCode;
}

class MerchantNotifier extends Notifier<MerchantProfile?> {
  static const _keyName = 'merchant_name';
  static const _keyCode = 'merchant_code';
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  @override
  MerchantProfile? build() {
    _restore();
    return null;
  }

  Future<void> _restore() async {
    final name = await _storage.read(key: _keyName);
    final code = await _storage.read(key: _keyCode);
    if (name != null && code != null) {
      state = MerchantProfile(businessName: name, momoPayCode: code);
    }
  }

  Future<void> save(MerchantProfile profile) async {
    await _storage.write(key: _keyName, value: profile.businessName);
    await _storage.write(key: _keyCode, value: profile.momoPayCode);
    state = profile;
  }

  Future<void> clear() async {
    await _storage.delete(key: _keyName);
    await _storage.delete(key: _keyCode);
    state = null;
  }
}

final merchantProvider =
    NotifierProvider<MerchantNotifier, MerchantProfile?>(MerchantNotifier.new);
