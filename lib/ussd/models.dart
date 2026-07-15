/// Remotely-updatable USSD menu trees (§3.3 of ZUNGA_BUILD.md).
///
/// Menu trees are data, never code: versioned JSON, Ed25519-signed,
/// fetched from the backend and cached locally. Nothing here hardcodes
/// a carrier menu beyond the bundled seed config.
library;

enum StepInputType { fixed, recipientMsisdn, amount, userPin, meterNumber, reference }

class UssdStep {
  const UssdStep({
    required this.expectContains,
    this.input,
    this.inputType = StepInputType.fixed,
  });

  /// Carrier strings to match, in rw/en/fr — the menu language follows
  /// the SIM setting, not the app.
  final List<String> expectContains;
  final String? input;
  final StepInputType inputType;

  factory UssdStep.fromJson(Map<String, dynamic> json) {
    final rawType = json['input_type'] as String?;
    return UssdStep(
      expectContains: List<String>.from(json['expect_contains'] as List? ?? const []),
      input: json['input'] as String?,
      inputType: switch (rawType) {
        'user_pin' => StepInputType.userPin,
        'recipient_msisdn' => StepInputType.recipientMsisdn,
        'amount' => StepInputType.amount,
        'meter_number' => StepInputType.meterNumber,
        'reference' => StepInputType.reference,
        _ => StepInputType.fixed,
      },
    );
  }

  /// True when the live carrier screen matches this step in any language.
  bool matches(String screenText) {
    if (expectContains.isEmpty) return true;
    final lower = screenText.toLowerCase();
    return expectContains.any((e) => lower.contains(e.toLowerCase()));
  }
}

class UssdFlow {
  const UssdFlow({
    required this.id,
    required this.root,
    required this.steps,
    required this.successContains,
    this.nameCheckStep,
    this.requiresFieldVerification = false,
  });

  final String id;

  /// The root code dialed to start this flow, e.g. `*182#` or `*182*1*2#`.
  final String root;
  final List<UssdStep> steps;
  final List<String> successContains;

  /// Index of the step whose screen carries the registered recipient name.
  final int? nameCheckStep;

  /// Set on flows whose deeper menu path has not yet been confirmed on a
  /// live SIM. The engine refuses to automate these and offers manual dial.
  final bool requiresFieldVerification;

  factory UssdFlow.fromJson(String id, Map<String, dynamic> json) => UssdFlow(
        id: id,
        root: json['root'] as String,
        steps: (json['steps'] as List? ?? const [])
            .map((s) => UssdStep.fromJson(s as Map<String, dynamic>))
            .toList(),
        successContains:
            List<String>.from(json['success_contains'] as List? ?? const []),
        nameCheckStep: json['name_check_step'] as int?,
        requiresFieldVerification:
            json['requires_field_verification'] as bool? ?? false,
      );

  bool isSuccess(String screenText) {
    final lower = screenText.toLowerCase();
    return successContains.any((e) => lower.contains(e.toLowerCase()));
  }
}

class ProviderConfig {
  const ProviderConfig({
    required this.provider,
    required this.displayName,
    required this.version,
    required this.minAppVersion,
    required this.flows,
  });

  final String provider;
  final String displayName;
  final int version;
  final String minAppVersion;
  final Map<String, UssdFlow> flows;

  factory ProviderConfig.fromJson(Map<String, dynamic> json) {
    final flowsJson = json['flows'] as Map<String, dynamic>? ?? const {};
    return ProviderConfig(
      provider: json['provider'] as String,
      displayName: json['display_name'] as String? ?? json['provider'] as String,
      version: json['version'] as int,
      minAppVersion: json['min_app_version'] as String? ?? '0.0.0',
      flows: flowsJson.map(
        (k, v) => MapEntry(k, UssdFlow.fromJson(k, v as Map<String, dynamic>)),
      ),
    );
  }
}

class MenuConfigBundle {
  const MenuConfigBundle({required this.generatedAt, required this.providers});

  final String generatedAt;
  final Map<String, ProviderConfig> providers;

  factory MenuConfigBundle.fromJson(Map<String, dynamic> json) {
    final list = json['providers'] as List? ?? const [];
    final map = <String, ProviderConfig>{};
    for (final p in list) {
      final cfg = ProviderConfig.fromJson(p as Map<String, dynamic>);
      map[cfg.provider] = cfg;
    }
    return MenuConfigBundle(
      generatedAt: json['generated_at'] as String? ?? '',
      providers: map,
    );
  }
}
