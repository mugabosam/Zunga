import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/tokens.dart';
import '../../l10n/app_localizations.dart';

/// Onboarding entry — value proposition, then phone OTP → PIN →
/// biometrics (Stage 1). OTP verification is stubbed until the Supabase
/// project is provisioned.
class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                child: const Text(
                  'Z',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(height: 28),
              Text(
                l.onboardingTitle,
                style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.96,
                    height: 1.15),
              ),
              const SizedBox(height: 14),
              Text(
                l.onboardingSubtitle,
                style: const TextStyle(
                    fontSize: 15, color: ZTokens.ink2, height: 1.55),
              ),
              const Spacer(),
              // The security promise, surfaced in the UI, not buried in a
              // policy page.
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: ZTokens.accentTint,
                  border: Border.all(color: ZTokens.accentBorder),
                  borderRadius: BorderRadius.circular(ZTokens.radius),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.lock_outline,
                        size: 20, color: ZTokens.accent),
                    const SizedBox(width: 13),
                    Expanded(
                      child: Text(
                        l.pinNeverLeaves,
                        style: const TextStyle(
                            fontSize: 12.5, color: ZTokens.ink2, height: 1.5),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => context.push('/onboarding/pin'),
                child: Text(l.getStarted),
              ),
              const SizedBox(height: 26),
            ],
          ),
        ),
      ),
    );
  }
}
