import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/tokens.dart';
import '../../core/widgets/kit.dart';
import '../../l10n/app_localizations.dart';
import '../../security/app_lock.dart';

/// Session lock overlay: shown after 60 s in background (§6.7).
class LockScreen extends ConsumerStatefulWidget {
  const LockScreen({super.key});

  @override
  ConsumerState<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends ConsumerState<LockScreen> {
  String _pin = '';
  String? _error;

  Future<void> _onDigit(String d) async {
    if (_pin.length >= 4) return;
    setState(() => _pin += d);
    if (_pin.length == 4) {
      final service = ref.read(pinServiceProvider);
      final lockout = await service.lockoutRemaining();
      if (lockout != null) {
        setState(() {
          _pin = '';
          _error = 'Locked — try again in ${lockout.inSeconds}s';
        });
        return;
      }
      final ok = !(await service.hasPin()) || await service.verifyPin(_pin);
      if (!mounted) return;
      if (ok) {
        ref.read(appLockProvider.notifier).unlock();
      } else {
        setState(() {
          _pin = '';
          _error = 'Wrong PIN';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            Container(
              width: 54,
              height: 54,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: ZTokens.ink,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text('Z',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w700)),
            ),
            const SizedBox(height: 24),
            Text(l.appLocked,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text(
              _error ?? l.enterPinToConfirm,
              style: TextStyle(
                fontSize: 13.5,
                color: _error != null
                    ? Theme.of(context).colorScheme.error
                    : ZTokens.ink2,
              ),
            ),
            const SizedBox(height: 28),
            PinDots(filled: _pin.length),
            const Spacer(),
            ZKeypad(
              onDigit: _onDigit,
              onBackspace: () {
                if (_pin.isNotEmpty) {
                  setState(() => _pin = _pin.substring(0, _pin.length - 1));
                }
              },
            ),
            const SizedBox(height: 22),
          ],
        ),
      ),
    );
  }
}
