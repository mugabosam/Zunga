import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/tokens.dart';
import '../../core/widgets/kit.dart';
import '../../core/widgets/scaffold.dart';
import '../../l10n/app_localizations.dart';
import '../../security/app_lock.dart';

/// PIN creation: enter, confirm, Argon2id-hash into secure storage.
class PinSetupScreen extends ConsumerStatefulWidget {
  const PinSetupScreen({super.key});

  @override
  ConsumerState<PinSetupScreen> createState() => _PinSetupScreenState();
}

class _PinSetupScreenState extends ConsumerState<PinSetupScreen> {
  String _first = '';
  String _current = '';
  bool _confirming = false;
  bool _saving = false;
  String? _error;

  Future<void> _onDigit(String d) async {
    if (_saving || _current.length >= 4) return;
    setState(() {
      _error = null;
      _current += d;
    });
    if (_current.length < 4) return;

    if (!_confirming) {
      setState(() {
        _first = _current;
        _current = '';
        _confirming = true;
      });
      return;
    }
    if (_current != _first) {
      setState(() {
        _current = '';
        _first = '';
        _confirming = false;
        _error = 'PINs did not match — start again';
      });
      return;
    }
    setState(() => _saving = true);
    await ref.read(pinServiceProvider).setPin(_current);
    if (mounted) context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: zAppBar(context, title: l.appPin),
      body: Column(
        children: [
          const Spacer(),
          Text(
            _confirming ? l.confirmPin : l.createPin,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            _error ?? l.requiredForEveryPayment,
            style: TextStyle(
              fontSize: 13.5,
              color: _error != null
                  ? Theme.of(context).colorScheme.error
                  : ZTokens.ink2,
            ),
          ),
          const SizedBox(height: 28),
          PinDots(filled: _current.length),
          const Spacer(),
          ZKeypad(
            onDigit: _onDigit,
            onBackspace: () {
              if (_current.isNotEmpty) {
                setState(() =>
                    _current = _current.substring(0, _current.length - 1));
              }
            },
          ),
          const SizedBox(height: 22),
        ],
      ),
    );
  }
}
