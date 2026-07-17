import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Registered-name lookup — the name on the ID behind a SIM, not the
/// nickname saved in contacts.
///
/// Rwanda has no public MSISDN→name directory: this data is only
/// reachable over the internet through a KYC partner API (MTN MoMo
/// `basicuserinfo`, or an aggregator such as Paypack) proxied by our
/// backend so no API key ships in the app. Until that endpoint is live,
/// `endpoint` stays null and the app falls back to the contact name +
/// the carrier's own name-confirm step inside the USSD session, which
/// always remains the final check.
///
/// The endpoint URL will ship inside the signed remote config, so
/// turning the feature on needs no app update.
class NameLookupService {
  const NameLookupService({this.endpoint});

  /// HTTPS endpoint returning `{"name": "UWASE Marie Claire"}` for
  /// `GET {endpoint}?msisdn=2507XXXXXXXX`. Null = feature not yet live.
  final String? endpoint;

  bool get isLive => endpoint != null;

  Future<String?> registeredName(String msisdn) async {
    final base = endpoint;
    if (base == null) return null;
    final digits = msisdn.replaceAll(RegExp(r'\D'), '');
    final e164 = digits.startsWith('250') ? digits : '250$digits';
    try {
      final client = HttpClient()..connectionTimeout = const Duration(seconds: 6);
      final request =
          await client.getUrl(Uri.parse('$base?msisdn=$e164'));
      final response = await request.close();
      if (response.statusCode != 200) return null;
      final body = await response.transform(utf8.decoder).join();
      final name = (jsonDecode(body) as Map<String, dynamic>)['name'];
      return name is String && name.trim().isNotEmpty ? name.trim() : null;
    } catch (_) {
      // Offline or endpoint down: the carrier confirm step still shows
      // the registered name before the PIN.
      return null;
    }
  }
}

final nameLookupProvider = Provider<NameLookupService>(
  // Endpoint arrives via the signed remote config once the KYC partner
  // API is provisioned; null keeps the graceful fallbacks active.
  (ref) => const NameLookupService(endpoint: null),
);
