import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../ussd/providers.dart';
import 'settings.dart';

/// Device contacts for the send screen — read on this phone only,
/// normalized to Rwandan mobile numbers, deduplicated. Empty when the
/// contacts toggle is off or the permission is denied.
class PhoneContact {
  const PhoneContact({required this.name, required this.msisdn});

  final String name;
  final String msisdn;

  String get initials => name
      .trim()
      .split(RegExp(r'\s+'))
      .take(2)
      .map((w) => w[0].toUpperCase())
      .join();
}

/// `+250 788 412 903`, `250788412903`, `788412903`, `0788 412 903` →
/// `0788412903`; anything that is not a Rwandan mobile returns null.
String? normalizeRwMsisdn(String raw) {
  var digits = raw.replaceAll(RegExp(r'\D'), '');
  if (digits.startsWith('250')) digits = digits.substring(3);
  if (digits.length == 9 && digits.startsWith('7')) digits = '0$digits';
  if (RegExp(r'^07[2389]\d{7}$').hasMatch(digits)) return digits;
  return null;
}

final contactsProvider = FutureProvider<List<PhoneContact>>((ref) async {
  if (!ref.watch(settingsProvider).enableContacts) return const [];
  final raw = await ref.read(ussdEngineProvider).getContacts();
  final seen = <String>{};
  final contacts = <PhoneContact>[];
  for (final (name, number) in raw) {
    final msisdn = normalizeRwMsisdn(number);
    if (msisdn == null || !seen.add(msisdn)) continue;
    contacts.add(PhoneContact(name: name, msisdn: msisdn));
  }
  return contacts;
});
