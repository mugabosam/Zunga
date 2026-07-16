# Zunga

**One app for every payment in Rwanda.** MTN MoMo, Airtel Money, banks via eKash, bills, government payments, ikimina and merchant tools — a pure interface layer over the user's **own USSD sessions on their own SIM**. Money never touches Zunga servers (Faranga model; no PSP/EMI license needed at launch).

- **Build spec:** [ZUNGA_BUILD.md](ZUNGA_BUILD.md) — architecture, security spec, staging, Play compliance.
- **Design system:** [zunga-ui.html](zunga-ui.html) — 22 screens, near-monochrome, one accent `#0E6E5C`, Inter + IBM Plex Mono, tabular numerals.

## How the rails actually work (verified July 2026)

- **eKash is the national interoperability rail**, operated by RSwitch. Since **14 July 2026** (BNR **Directive No. 45/2026**) all domestic interoperable retail payments between banks and e-money issuers route through eKash — fee **capped at 20 RWF**, up to **10M RWF** per transaction, settlement under 15 s.
- **`*182*1*2#` is the cross-network send code and works from any network** (confirmed by Airtel Rwanda & Airtel Money Rwanda). Recipient phone number = eKash ID; the carrier shows the registered name before PIN confirmation.
- **The standalone eKash *wallet* is being phased out** — do not surface `*182*11#` (old wallet activation). Users transact through their own carrier/bank channel; eKash routes underneath.
- Carrier roots: MTN MoMo `*182#`, Airtel Money `*500#`. Bank USSD shortcodes are intentionally **not** hardcoded — they change without notice and are verified per bank during Stage 3 field testing.
- Deep menu trees ship as **Ed25519-signed, remotely-updatable JSON** ([assets/configs/menu_configs.json](assets/configs/menu_configs.json)); anything not yet confirmed on a live SIM carries `requires_field_verification: true` and the engine **fails closed** (manual dial is always offered).

## Project layout

```text
lib/
  core/        theme (design tokens), router, widgets kit, l10n, sample data
  security/    Argon2id app PIN, session lock (60 s), secure storage
  ussd/        engine, signed-config pipeline, menu-tree models, pinned key
  insights/    on-device SMS parser (allowlisted senders only)
  features/    home, send, pay, bills, accounts, merchant_pay, government,
               tools (split/ikimina/scheduled), merchant_mode, settings,
               onboarding + lock — all 22 design screens
android/
  .../rw/zunga UssdChannel.kt (sendUssdRequest, dual-SIM, manual dial),
               ZungaAccessibilityService.kt (bound ONLY to com.android.phone)
tool/          sign_config.dart — dev Ed25519 signer (prod key is offline)
```

## Getting started

```bash
flutter pub get
dart run tool/sign_config.dart   # generates dev key + signs the menu config
flutter run                      # Android device/emulator (minSdk 26)
flutter test                     # 18 tests: config integrity, routing, SMS parser
```

`tool/dev_key.json` is git-ignored; each checkout generates its own dev signing key and re-pins it. The production signing key never enters this repository.

## Security invariants (enforced, not aspirational)

- Carrier/bank PINs: in-memory only, zeroed after injection, never persisted or logged — **CI greps `lib/ussd` and `lib/security` and fails the build on any logger call**.
- App PIN: Argon2id (32 MiB, 3 iters), salted, secure storage; 5 fails → doubling backoff.
- Configs: Ed25519 signature + monotonic version (no rollback), key pinned in binary.
- `FLAG_SECURE` on every screen; `allowBackup=false`; cleartext traffic rejected.
- Accessibility service scope locked to the carrier USSD dialog package.
- Scam interstitial: **Cancel is always the primary action**; name-check failure blocks by default.

## Localization

Kinyarwanda (default when device is `rw`), English, Français — `lib/l10n/app_*.arb`. Carrier-string matching in menu configs carries all three languages because the USSD menu language follows the SIM, not the app.

## Status

Stage 1–2 skeleton: design system, all 22 screens, USSD engine + signed config pipeline, security shell, sample data. Next per [ZUNGA_BUILD.md](ZUNGA_BUILD.md) §5: Supabase config distribution, SMS reconciliation, Kigali field verification of every flagged menu tree.
