# Zunga

**Stop typing the `*` strings.** Zunga is a USSD shortcut layer for payments in Rwanda: enter the amount and a phone number or MoMo Pay code in a clean UI, tap Pay, and land in your phone's dialer with the right code prefilled — press call and type only your carrier PIN. **Zunga never holds, moves, or sees money.** The transfer happens entirely inside your carrier's own USSD session, and every fee you see there is the carrier's or eKash's, never Zunga's.

- **Build spec:** [ZUNGA_BUILD.md](ZUNGA_BUILD.md) · **Design system:** [zunga-ui.html](zunga-ui.html)

## The codes it dials (verified July 2026)

| You want to | Zunga dials |
| --- | --- |
| Send MTN → MTN | `*182*1*1*number*amount#` (only the PIN left) |
| Send MTN ↔ Airtel (either direction) | `*182*1*2#` — eKash, works from any network |
| Pay a merchant (MoMo Pay) | `*182*8*1*code#` |
| Airtel → Airtel | `*500#` (Airtel Money menu) |
| Send from a bank via eKash | that bank's own access code (table below) |

Full eKash access-code table shipped in-app and in the signed config: MTN MoMo / Airtel Money `*182*1*2#`, Bank of Kigali `*334*2*4#`, Equity `*555*2#`, GT Bank `*600*7*2#`, Bank of Africa `*512*2*2#`, Copedu `*866*3#`, I&M `*227*4*3#`, Ecobank `*883*8*1#`, Zigama CSS `*139*5*3#`, AB Bank `*540*2*3#`, Umwalimu Sacco `*175*3#`, BPR `*150*3*4#`, LOLC Unguka `*951*4#`, Access Bank `*903*3*5#`, Letshego `*598*1*3#`, Mvend `*737*1*2#`, NCBA `*650*1*2#`, Jali `*655*8*3#` (Chipper Cash is app-only).

Context: eKash is the national interoperability rail (RSwitch); since 14 July 2026 (BNR Directive No. 45/2026) all domestic interoperable retail payments route through it — fee capped at 20 RWF, up to 10M RWF per transaction. The old standalone eKash wallet (`*182*11#`) is phased out and never surfaced.

## Design decisions

- **No app PIN, no onboarding wall.** Zunga stores no money and no secrets — the only PIN that matters is your carrier's, typed in the carrier's own dialog.
- **Hand-off, not automation.** Pay buttons open the dialer via `ACTION_DIAL` with the full code visible; the user always presses call themselves. No permission needed, nothing fires blind.
- **No fake data.** No mock balances, contacts, or transactions. The activity tab is an honest empty state until on-device SMS tracking ships (parser already in `lib/insights/`, allowlisted senders only, nothing leaves the phone).
- **Codes are data.** Dial codes ship as Ed25519-signed JSON (`assets/configs/`) with a pinned key and rollback protection, so a changed carrier menu is fixed remotely — no app update. Inline templates (`*182*1*1*{msisdn}*{amount}#`) are confirmed on live SIMs and correctable the same way.

## Project layout

```text
lib/
  core/        theme tokens, router, widget kit, locale, eKash directory
  ussd/        engine (dial hand-off, dual-SIM), signed-config pipeline
  insights/    on-device SMS parser (future activity feed)
  features/    home, send (amount → number-or-code → dialer), pay hub,
               bills, bank transfer, eKash codes directory, government,
               profile
android/.../rw/zunga   UssdChannel.kt, ZungaAccessibilityService.kt (future
                       deep automation, scoped to com.android.phone)
tool/sign_config.dart  dev Ed25519 signer (prod key stays offline)
```

## Getting started

```bash
flutter pub get
dart run tool/sign_config.dart   # generate dev key + sign the code table
flutter run                      # Android, minSdk 26
flutter test                     # 23 tests: codes, routing, signatures, SMS parser
```

## Localization

Kinyarwanda (default when device is `rw`), English, Français — `lib/l10n/app_*.arb`.
