import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/data/profile.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/kit.dart';
import '../send/send_flow_state.dart';

/// First run: register the number you will pay from. This is the only
/// setup step — it tells Zunga which SIM your transactions come from,
/// so the right code fires on the first try.
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  String _number = '';

  @override
  Widget build(BuildContext context) {
    final detected = detectNetwork(_number);
    final canContinue = _number.length == 10 && detected != null;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 40, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: ZTokens.ink,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Text('Z',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w700)),
                  ),
                  const SizedBox(height: 22),
                  const Text(
                    'Your number',
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.44),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'The MoMo or Airtel Money number you pay from. Stored on '
                    'this phone only.',
                    style: TextStyle(
                        fontSize: 13.5, color: ZTokens.ink2, height: 1.55),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _number.isEmpty ? '07•• ••• •••' : _formatNumber(_number),
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w700,
                        fontFeatures: ZTokens.numFeatures,
                        color: _number.isEmpty ? ZTokens.ink3 : ZTokens.ink,
                      ),
                    ),
                    const SizedBox(height: 14),
                    if (detected != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: ZTokens.accentTint,
                          borderRadius:
                              BorderRadius.circular(ZTokens.radiusPill),
                        ),
                        child: Text(
                          detected == 'MTN'
                              ? 'MTN MoMo number'
                              : 'Airtel Money number',
                          style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: ZTokens.accent),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            ZKeypad(
              onDigit: (d) {
                if (_number.length < 10) setState(() => _number += d);
              },
              onBackspace: () {
                if (_number.isNotEmpty) {
                  setState(
                      () => _number = _number.substring(0, _number.length - 1));
                }
              },
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 22),
              child: FilledButton(
                onPressed: canContinue
                    ? () async {
                        await ref
                            .read(myNumberProvider.notifier)
                            .register(_number);
                        if (context.mounted) context.go('/home');
                      }
                    : null,
                child: const Text('Continue'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatNumber(String raw) {
    final b = StringBuffer();
    for (var i = 0; i < raw.length; i++) {
      if (i == 4 || i == 7) b.write(' ');
      b.write(raw[i]);
    }
    return b.toString();
  }
}
