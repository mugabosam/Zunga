import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// People you have paid before — number, best-known name, network and
/// when. Saved on-device (Hive) after every pay so next time the number
/// is one tap away. No server ever sees this list.
class RecentRecipient {
  const RecentRecipient({
    required this.msisdn,
    this.name,
    this.network,
    required this.lastPaidAt,
  });

  final String msisdn;
  final String? name;
  final String? network;
  final DateTime lastPaidAt;

  Map<String, dynamic> toMap() => {
        'msisdn': msisdn,
        'name': name,
        'network': network,
        'lastPaidAt': lastPaidAt.toIso8601String(),
      };

  factory RecentRecipient.fromMap(Map<dynamic, dynamic> map) => RecentRecipient(
        msisdn: map['msisdn'] as String,
        name: map['name'] as String?,
        network: map['network'] as String?,
        lastPaidAt:
            DateTime.tryParse(map['lastPaidAt'] as String? ?? '') ?? DateTime.now(),
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

class RecentsNotifier extends Notifier<List<RecentRecipient>> {
  static const _boxName = 'recents';

  @override
  List<RecentRecipient> build() {
    _load();
    return const [];
  }

  Future<void> _load() async {
    final box = await Hive.openBox<Map>(_boxName);
    state = _sorted(box.values.map(RecentRecipient.fromMap).toList());
  }

  Future<void> remember(RecentRecipient recipient) async {
    final box = await Hive.openBox<Map>(_boxName);
    await box.put(recipient.msisdn, recipient.toMap());
    state = _sorted(box.values.map(RecentRecipient.fromMap).toList());
  }

  List<RecentRecipient> _sorted(List<RecentRecipient> list) {
    list.sort((a, b) => b.lastPaidAt.compareTo(a.lastPaidAt));
    return List.unmodifiable(list.take(20));
  }
}

final recentsProvider =
    NotifierProvider<RecentsNotifier, List<RecentRecipient>>(RecentsNotifier.new);
