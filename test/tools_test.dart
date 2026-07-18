import 'package:flutter_test/flutter_test.dart';
import 'package:zunga/core/data/tools.dart';

void main() {
  group('Split — equal shares always add up exactly', () {
    test('clean division', () {
      expect(equalShares(24000, 4), [6000, 6000, 6000, 6000]);
    });

    test('remainder spreads over the first shares', () {
      final shares = equalShares(10000, 3);
      expect(shares, [3334, 3333, 3333]);
      expect(shares.reduce((a, b) => a + b), 10000);
    });

    test('degenerate inputs', () {
      expect(equalShares(5000, 0), isEmpty);
      expect(equalShares(0, 3), [0, 0, 0]);
    });

    test('collected counts only paid participants', () {
      final split = SplitRequest(
        id: 's1',
        title: 'Dinner',
        total: 12000,
        participants: const [
          SplitParticipant(msisdn: '0788000001', share: 6000, paid: true),
          SplitParticipant(msisdn: '0733000002', share: 6000),
        ],
        createdAt: DateTime(2026, 7, 18),
      );
      expect(split.collected, 6000);
    });
  });

  group('Ikimina — pot math and round rotation', () {
    final group = IkiminaGroup(
      id: 'g1',
      name: 'Abadahigwa',
      contribution: 20000,
      members: const [
        IkiminaMember(name: 'Sam', paid: true),
        IkiminaMember(name: 'Alexis', paid: true),
        IkiminaMember(name: 'Diane'),
      ],
    );

    test('pot is contribution × paid members', () {
      expect(group.pot, 40000);
      expect(group.paidCount, 2);
    });

    test('receiver rotates and payments reset on next round', () {
      expect(group.receiver!.name, 'Sam');
      final next = group.nextRound();
      expect(next.round, 2);
      expect(next.receiver!.name, 'Alexis');
      expect(next.paidCount, 0, reason: 'everyone unpaid again');
      expect(next.pot, 0);
    });

    test('rotation wraps around the member list', () {
      final third = group.nextRound().nextRound();
      expect(third.receiver!.name, 'Diane');
      expect(third.nextRound().receiver!.name, 'Sam');
    });

    test('serialization roundtrip', () {
      final restored = IkiminaGroup.fromMap(group.toMap());
      expect(restored.name, 'Abadahigwa');
      expect(restored.members.length, 3);
      expect(restored.pot, 40000);
    });
  });
}
