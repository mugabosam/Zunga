# CLAUDE.md — Zunga

Read this first, every session. It is the contract for how this app is built.

## What Zunga is (and is not)

Zunga is a **USSD shortcut layer** for payments in Rwanda — Android-first, Flutter.
The user enters an amount and a destination in a clean UI; the app composes the
correct carrier/bank USSD code and runs it, so the carrier's own session asks
for the PIN. That is the entire product.

**Non-negotiable — never violate these:**
- Zunga **never holds, moves, sees, or processes money.** Every payment happens
  inside the carrier's/bank's own USSD session on the user's own SIM.
- Zunga **never sees or stores a carrier/bank PIN.** The PIN is typed into the
  carrier's own popup. Never log, persist, or transmit it. A CI grep gate fails
  the build on any logging call in `lib/ussd/` or `lib/security/`.
- Zunga **charges nothing on a transaction.** Fees shown/charged are the
  carrier's, the bank's, or eKash's (capped at 20 RWF). Revenue is only the
  future merchant subscription.
- **No app PIN, no onboarding wall, no coach marks.** The only setup is
  registering the number you pay from. After Pay, go straight to the USSD
  session — no "MTN will ask for your PIN" explainer.
- **No mock/fake data — ever.** No invented balances, contacts, transactions, or
  group members. Use real on-device data or an honest empty state.
- **No invented USSD codes.** Every code must be verified (carrier/RSwitch/live
  SIM). If unverified, gate it behind `requires_field_verification` and offer
  manual dial. Never "suppose" a code.
- **Professional tone, not a student demo.** Users understand mobile money.
  Minimal helper/tutorial copy — cut subtitles that explain the obvious.

## Verified USSD codes (July 2026)

| Action | Code |
| --- | --- |
| MTN → MTN send | `*182*1*1*{number}*{amount}#` (inline, only PIN left) |
| Airtel → Airtel send | `*500*1*1*{number}*{amount}#` (inline, only PIN left) |
| Cross-network send (eKash, any direction) | `*182*1*2#` |
| MoMo Pay merchant | `*182*8*1*{code}#` |
| MTN balance | `*182*6*1#` |
| Airtel balance | `*500*5*1*1#` |
| MTN withdraw | `*182*7*2#` |
| Airtel withdraw | pending — opens `*500#` menu until provided |
| MTN menu root | `*182#` · Airtel menu root `*500#` |

eKash bank access codes (BK `*334*2*4#`, Equity `*555*2#`, etc.) live in
`assets/configs/menu_configs.json` and `lib/core/data/sample_data.dart`
(`ekashInstitutions`). Deprecated: `*182*11#` (old eKash wallet) — never surface.

Codes ship as **Ed25519-signed JSON** (`assets/configs/menu_configs.json`),
public key pinned in `lib/ussd/pinned_keys.dart`. After editing the config,
re-sign: `dart run tool/sign_config.dart`. Codes are data, not hardcoded logic —
correctable remotely without an app update.

## Design system (navy / orange)

- Background `#F6F6FA`, white cards with soft shadows (no hairline-only borders),
  navy `#232C63` primary, single orange accent `#EE7B3F` (tint `#FDEEE4`),
  ink `#232C63`, secondary `#7A80A0`. **Poppins** typeface, IBM Plex Mono for
  tokens/references. Radii 16–28px. Tabular numerals on every amount.
- All tokens in `lib/core/theme/tokens.dart`; theme in `theme.dart`. Shared
  widgets in `lib/core/widgets/kit.dart` — reuse these, do not re-roll cards,
  rows, pills, keypad.
- **Home** is keypad-first and matches the Faranga *structure* (not colors):
  menu button, amount card with 🇷🇼 + carrier chip, keypad, docked white bar
  with Balance + Pay. Home is **rigid** — `resizeToAvoidBottomInset: false`,
  never scrolls; card height and keypad rows adapt to the screen instead.
- Bottom navigation was replaced by a **navy side drawer** (`drawer.dart`,
  square corners). Splash: native system splash (Z mark on app background) →
  animated light-sweep splash (`splash_screen.dart`) → home/register.
- Masked identifiers everywhere (`+250 78x ··· xxx`, `··8901`).
- Localized rw/en/fr from `lib/l10n/app_*.arb`; Kinyarwanda default when device
  locale is `rw`. No hardcoded user-facing literals where a string exists.

## Architecture

```
lib/
  core/data/       profile (registered number, active wallet), settings,
                   recents, transactions (lifecycle), contacts, name_lookup,
                   tools (split/ikimina/merchant), sample_data (eKash directory)
  core/theme/      tokens, theme
  core/widgets/    kit (shared components), drawer, scaffold
  core/router/     go_router; /splash → gate → /register or /home
  ussd/            engine (dial + session + dual-SIM), signed config pipeline
  insights/        on-device SMS parser (future confirmation source)
  features/        home, send, pay, activity, accounts, bills, government,
                   tools, merchant_mode, settings, legal, onboarding
android/.../rw/zunga  UssdChannel.kt, MainActivity.kt (shortcuts, shareApk,
                      contacts), ZungaAccessibilityService.kt
tool/sign_config.dart  dev Ed25519 signer (prod key stays offline)
```

- State: **Riverpod** (Notifier/Provider). Local storage: **Hive** (transactions,
  recents, tools) + **flutter_secure_storage** (registered number, active wallet,
  settings, merchant profile). Nothing syncs to a server yet.
- **Transaction lifecycle (anti-Faranga):** `awaitingPin → pendingConfirmation →
  confirmed | failed | cancelled`. Only `confirmed` appears in totals/stats.
  Never record a payment at button-press. Corrupt status degrades to pending,
  never confirmed. See `lib/core/data/transactions.dart`.
- **Name resolution order (never show "Unknown"):** registered-name lookup
  (internet KYC endpoint, config-driven, currently null) → recents → device
  contacts → double-check note. Carrier confirm step is the final check.
- Payment runs via `engine.launchUssd(code)` (ACTION_CALL, carrier popup in
  place; ACTION_DIAL fallback only if call permission not yet granted). Network
  is detected (078/079 MTN, 072/073 Airtel) and from the registered SIM — never
  asked.

## Legal / sharing

- Privacy & Terms are **in-app screens** (`lib/features/legal/legal_screen.dart`),
  not .md files, not GitHub links.
- "Share the app" shares the **actual APK build** (native `shareApk` via
  FileProvider) during development. At production this becomes a Play Store link.
  Only ever distribute a **release** APK (`flutter build apk --release`, or the
  `zunga-release-apk` CI artifact) — a debug APK crashes when sideloaded because
  it expects the dev/JIT connection.
- WhatsApp support opens the app (`whatsapp://`, number 0728670972), web fallback.

## Workflow

- Repo: `github.com/mugabosam/Zunga`, branch `main`.
- **Commits: no `Co-Authored-By` trailer.** (See project memory.)
- Before pushing: `flutter analyze` (must be clean) → `flutter test` (all pass) →
  `flutter build apk --debug` (must build). Then commit + push.
- Windows dev machine; use forward-slash paths in Dart, PowerShell/Bash for shell.
- Out of scope v1: holding funds, direct eKash/MoMo APIs (needs registered
  company), lending, iOS, crypto, cross-border. iOS is impossible for the core
  engine (no programmatic USSD / SMS / accessibility on iOS).

## Source-of-truth docs

- `ZUNGA_PROMPT.md` — master execution prompt (UI restructure, the two Faranga
  flaws, build order).
- `ZUNGA_BUILD.md` — full architecture/security/stages spec.
- `zunga-ui.html` — visual design system reference.
