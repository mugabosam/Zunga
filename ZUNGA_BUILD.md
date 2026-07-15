# ZUNGA_BUILD.md — Build Specification

**Product:** Zunga (working name) — one app for every payment in Rwanda.
**Platform:** Android-first (Flutter). iOS later via web-dialing fallback.
**Model:** Pure interface layer over the user's own USSD sessions. Money NEVER touches Zunga servers. No PSP/EMI license required at launch (Faranga model). Direct eKash API integration is a Phase-3 decision only.
**Design system:** Implemented exactly per `zunga-ui.html` (22 screens). Background #FAFAF8, ink #141517, secondary #6B6E73, hairlines #E8E8E4, single accent #0E6E5C, Inter + tabular numerals, IBM Plex Mono for tokens/references, 16px radii, 8pt grid, light mode first.

---

## 1. Positioning and non-negotiables

1. Breadth is the product: MoMo + Airtel + banks via eKash + every bill + government payments in one interface. Do not compete with Faranga on "fast MoMo transfers" alone.
2. The merchant side (income tracking, RRA-ready records) is the monetization wedge. Consumer app is free forever.
3. Security is a feature users can see: verified-name-before-send, scam alerts, "your PIN never leaves this phone" messaging surfaced in the UI, not buried in a policy page.
4. Works on low-end Android (2 GB RAM, Android 8.0 / API 26 minimum) and without mobile data for core flows — USSD needs no internet.
5. Kinyarwanda, English, Français from day one. Kinyarwanda is the default when device locale is rw.

---

## 2. Tech stack

| Layer | Choice | Why |
|---|---|---|
| App | Flutter 3.x, Dart 3 | Sam's toolkit, single codebase, low-end device performance |
| State | Riverpod 2 (code-gen) | Established pattern from BlueSnap/EquipShare |
| Local DB | Hive (AES-encrypted boxes) | Offline-first, fast on low-end devices |
| Key storage | flutter_secure_storage (Android Keystore) | Hardware-backed keys |
| Backend | Supabase (Postgres, RLS, Edge Functions) | Config distribution, scam DB, ikimina/splits sync, analytics |
| Native bridge | Kotlin platform channels | USSD engine, Accessibility Service, SMS reader |
| Auth | Supabase phone OTP + local PIN + biometrics | Phone number is the identity in Rwanda |
| Crash/analytics | Sentry (self-hosted or EU region), PostHog | No PII in events — see §6.9 |
| CI | GitHub Actions → Play internal track | Signed AAB, obfuscated |

Nothing financial is processed server-side. Supabase holds: signed USSD menu configs, scam-report aggregates, ikimina/split group metadata, device registration, and anonymized analytics. It never holds balances, PINs, transaction amounts tied to identity, or SMS contents.

---

## 3. Architecture

### 3.1 Modules (feature-first folders)

```
lib/
  core/            # theme, router, l10n, errors, logging
  security/        # pin, biometrics, root check, session lock, crypto
  ussd/            # engine, menu-tree runtime, session manager
  accounts/        # linked wallets & banks, balances
  send/            # P2P: MoMo, Airtel, eKash cross-network
  merchant_pay/    # MoMo Pay codes, nearby suggestions
  bills/           # EUCL, WASAC, TV, airtime & bundles
  government/      # Irembo, RRA, Mutuelle, school fees
  tools/           # split, ikimina, scheduled
  insights/        # SMS parser, categorization, charts
  merchant_mode/   # income dashboard, RRA export
  settings/        # language, security toggles, accounts
```

### 3.2 The USSD engine (the heart of the app)

Native Kotlin service exposed over a platform channel.

- Single-step: `TelephonyManager.sendUssdRequest()` (API 26+), per-SIM via `SubscriptionManager` for dual-SIM phones (very common in Rwanda — MTN + Airtel in one device).
- Multi-step menus: an Accessibility Service reads the carrier USSD dialog, matches the expected screen, and injects the next input. This is the fragile part — treat every automated menu as a scraper.
- Session manager: one USSD session at a time, global lock, 30 s step timeout, automatic cancel + user-readable error on mismatch ("MTN changed this menu — we're updating it, use manual mode meanwhile").
- Manual fallback ALWAYS available: every automated flow has a "Dial myself" button that opens the raw USSD code so the user is never blocked by a broken tree.
- PIN step: the engine pauses and the USER types their carrier/bank PIN into the carrier's own dialog whenever possible. Where the flow requires Zunga to relay the PIN (some trees), it is read from an in-memory field, injected, and zeroed immediately. It is never written to disk, logs, analytics, or crash reports (§6.2).

### 3.3 Remotely-updatable menu trees (never hardcode)

Menu trees live in Supabase as versioned JSON, fetched at app start and cached in Hive.

```json
{
  "provider": "mtn_momo",
  "version": 41,
  "min_app_version": "1.2.0",
  "flows": {
    "send_p2p": {
      "root": "*182#",
      "steps": [
        {"expect_contains": ["Transfer", "Kohereza"], "input": "1"},
        {"expect_contains": ["phone number"], "input": "{recipient_msisdn}"},
        {"expect_contains": ["amount"], "input": "{amount}"},
        {"expect_contains": ["confirm", "Emeza"], "input_type": "user_pin"}
      ],
      "success_contains": ["successful", "Byagenze neza"],
      "name_check_step": 3
    }
  }
}
```

- **Configs are signed.** Ed25519 signature over the JSON, public key pinned in the app binary. An unsigned or tampered config is rejected — this prevents a compromised backend from redirecting users' money (§6.5).
- `expect_contains` arrays include Kinyarwanda, English, and French carrier strings.
- When a step mismatch is detected, the app reports (menu text hash only, no user data) so broken trees are noticed within hours, fixed server-side, and pushed without an app release.

Providers to map at launch: MTN MoMo (*182#), Airtel Money (*500#), eKash activation (*182*11#) and cross-network send (*182*1*2#), Bank of Kigali, Equity, I&M, Ecobank USSD menus (verify each bank's live shortcode and tree during build — do not trust any hardcoded list, banks change these without notice).

### 3.4 SMS parser (insights without servers)

- Reads ONLY sender IDs on an allowlist (M-Money, AirtelMoney, bank sender IDs). Regex/parse locally on-device into structured transactions (amount, counterparty, fee, balance, ref).
- Raw SMS text never leaves the device. Parsed transactions are stored in encrypted Hive only.
- Powers: activity feed, weekly insights, income tracking, merchant mode, and reconciliation of USSD sessions (a send is only marked "successful" when the confirming SMS arrives or the USSD success string matched).
- READ_SMS is a sensitive permission — see §8 Play compliance for the declaration strategy and the no-SMS fallback mode (manual entry + USSD result parsing only).

### 3.5 Offline-first

- All history, saved billers, meter numbers, groups, and schedules readable with zero connectivity.
- USSD flows work without data by definition. The only online-required features: config refresh, scam DB sync, ikimina/split group sync, nearby merchants. Each degrades gracefully with a clear offline banner.

---

## 4. Data models (Hive, all boxes AES-encrypted)

- **LinkedAccount** — id, type (momo|airtel|bank), provider, masked identifier, simSlot, lastBalance (nullable, user-refreshed), createdAt.
- **Transaction** — id, direction, amount, fee, counterpartyName, counterpartyMsisdnMasked, provider, category, source (ussd|sms), ref, status, timestamp.
- **Biller** — type (eucl|wasac|canal|dstv|startimes|irembo|rra|mutuelle|school), accountNumber, nickname, usualAmount, lastPaidAt, expiryOrDueAt.
- **ScheduledPayment** — billerOrRecipient, amount, rrule (RFC 5545 subset), nextRunAt, remindOnly (bool — reminders vs prepared payments; execution ALWAYS requires user PIN, no silent sends, ever).
- **IkiminaGroup** (synced) — id, name, members[], contributionAmount, cadence, roundOrder[], currentRound, payoutDate, paidStatus{}.
- **SplitRequest** (synced) — id, title, total, participants[], perPersonAmounts, paidStatus{}, createdAt.
- **HouseholdMember** — name, mutuelleYearPaid{}, receiptRef.
- **MerchantProfile** — businessName, momoPayCode, dailyTotals cache.

Server-side (Supabase, RLS on every table): profiles (phone, display name), ikimina_groups + members, split_requests + participants, scam_reports (reporter hashed), menu_configs, device_registrations. RLS: members read/write only their groups; scam aggregates are public-read, report-write authenticated + rate-limited.

---

## 5. Feature build stages

Build in this order; each stage ships to the internal track before the next starts.

**Stage 1 — Foundation & security shell.** Theme/tokens from zunga-ui.html, router, l10n scaffolding (rw/en/fr), onboarding (phone OTP → app PIN → biometrics opt-in), root/integrity checks, encrypted Hive, secure session lock (auto-lock 60 s background), settings screen 22.
**Stage 2 — USSD engine + MoMo/Airtel send.** Engine, signed config pipeline, dual-SIM routing, send flow (screens 02-04, 08, 10): contacts + manual number entry, amount, **registered-name verification before send** (parse the carrier's name-confirmation step and show it in the verify card), PIN, success. SMS confirmation reconciliation.
**Stage 3 — eKash + banks.** Cross-network send via eKash tree, bank↔wallet transfers (screen 12), linked accounts manager (screen 13), per-bank menu mapping for BK/Equity/I&M/Ecobank, balance refresh flows.
**Stage 4 — Bills.** Bills hub (05), EUCL token purchase with saved meters + one-tap usual amount + token result screen (06, copy/share), WASAC lookup/pay, TV decoders with expiry reminders, airtime & bundles with auto top-up schedules (14).
**Stage 5 — Insights & activity.** SMS parser, categorization, activity feed + weekly chart (07), income tracking.
**Stage 6 — Government.** Government hub (18), Irembo reference payments, RRA reference payments, Mutuelle household tracker with per-member status and December reminders (19), school fees by reference.
**Stage 7 — Tools.** Split a bill with SMS fallback requests (15), ikimina groups: rounds, whose-turn, paid/pending, reminders (16), scheduled payments & reminders (17).
**Stage 8 — Protection.** Scam DB sync, reported-number warning interstitial (20), name-mismatch heuristic, community reporting flow, fraud education cards.
**Stage 9 — Merchant mode.** Business profile, daily/weekly income dashboard (21), customer payments feed, monthly statement export (PDF + CSV, RRA-ready fields: date, ref, gross, fee, net) — this is the paid tier.
**Stage 10 — Hardening & launch.** §6 checklist end-to-end, pen-test pass, Play pre-launch report, obfuscation verification, Kigali field testing on MTN + Airtel low-end devices, closed beta (moto drivers + small shop owners), public launch.

---

## 6. Security specification (non-negotiable, test every item)

### 6.1 Threat model summary
Assets: user's mobile-money/bank PINs, transaction history, contact graph, SMS contents, menu configs (integrity), scam DB (integrity). Adversaries: device thieves, malware on-device, network MITM, a compromised Zunga backend, malicious insiders, scammers targeting users socially.

### 6.2 PIN & credential handling
- Carrier/bank PINs: never persisted, never logged, never in analytics/crash breadcrumbs, never in the Flutter widget tree longer than needed (use obscured native input where relayed), zeroed after injection. Add a lint/CI grep gate that fails the build if any logger call sits in `ussd/` or `security/`.
- Zunga app PIN: 4-6 digits, stored as Argon2id hash (salted) in secure storage; 5 failed attempts → 30 s backoff doubling; verified locally, never transmitted.
- Biometrics via BiometricPrompt, keys in Android Keystore (StrongBox where available), `setUserAuthenticationRequired(true)`.

### 6.3 Data at rest
- Every Hive box AES-256 encrypted; box keys generated on first run, wrapped by a Keystore master key.
- No financial data in SharedPreferences, external storage, or backups: `android:allowBackup="false"`, `fullBackupContent` off, exclude from Auto Backup.
- Exports (merchant statements) are generated on demand to app-private storage and shared via FileProvider with temporary read permission only.

### 6.4 Data in transit
- TLS 1.2+ only; certificate pinning (Supabase + config CDN) with a pinned backup key and a remote kill-switch config for pin rotation.
- Reject cleartext: `usesCleartextTraffic="false"`, network security config enforced.

### 6.5 Config & supply-chain integrity
- Ed25519-signed menu configs (public key in binary); reject unsigned/rolled-back versions (monotonic version check).
- Dependencies locked (pubspec.lock committed), `flutter pub outdated` + `osv-scanner` in CI, no dynamic code loading.
- Release signing key in Play App Signing; upload key in a hardware-backed CI secret.

### 6.6 App & device integrity
- Play Integrity API verdict checked at onboarding and before high-risk actions; degraded (warn, don't hard-block) on failure — rooted-device users get a persistent warning banner and no cached balances.
- Root/emulator/hooking detection (Frida/Xposed indicators) → warning + telemetry flag.
- `FLAG_SECURE` on all screens showing balances, tokens, or PIN entry (blocks screenshots/screen recording); disable Android "recent apps" thumbnail leakage.
- R8/ProGuard obfuscation + resource shrinking; `flutter build --obfuscate --split-debug-info`.

### 6.7 Session & UI security
- Auto-lock after 60 s in background; PIN/biometric to reopen. Sensitive actions (send, connect account, disable protections) always re-prompt.
- Tapjacking protection (`filterTouchesWhenObscured`) on confirm buttons.
- Accessibility Service scope: bound ONLY to carrier USSD dialog package/window class; ignores every other app; this must be provable in code review (Play will check).

### 6.8 Anti-fraud (user-facing security)
- Registered-name verification card before every send; block-by-default if the carrier name step fails to parse (fail closed, offer manual dial).
- Scam DB: phone-number hashes (SHA-256, salted server-side) with report counts + pattern labels; interstitial (screen 20) when a recipient matches; "Cancel" is always the primary action.
- Rate-limit and dedupe community reports; require a completed app profile to report; never expose reporter identity.
- New-recipient friction: first-ever send to a number above 100,000 RWF adds a hold-to-confirm step.

### 6.9 Privacy & compliance (Rwanda Law No. 058/2021 on personal data protection)
- Data minimization: server never sees SMS text, balances, amounts-with-identity, or contact lists. Contact matching for splits/ikimina uses locally hashed numbers.
- Explicit consent screens for READ_SMS and Accessibility, each with a plain-language Kinyarwanda/English/French explanation of exactly what is read and why, and a working no-consent mode.
- In-app data export and delete-account (wipes local boxes + server rows).
- Analytics: event names only, no payloads containing numbers, names, or amounts; IP truncation on.
- Register as data controller with the NCSA Data Protection Office before public launch.

### 6.10 Incident readiness
- Remote feature-flag kill switches per provider flow (pause "MTN send" instantly if a tree change risks misrouting money).
- Signed config rollback path; on-call config editor runbook.
- security.txt + responsible disclosure policy; log retention 30 days, no PII.

---

## 7. Localization

- flutter_localizations + ARB files: `app_rw.arb` (default), `app_en.arb`, `app_fr.arb`. All 22 screens' strings externalized from Stage 1 — no hardcoded literals (CI grep gate).
- Amounts: `NumberFormat` with thousands separators, RWF suffix, tabular numerals.
- Carrier-string matching in menu configs carries all three languages (§3.3) because the carrier menu language follows the SIM setting, not the app.

---

## 8. Google Play compliance plan (the real launch risk)

- **Accessibility Service:** declare with the `accessibility_tool` policy path is NOT applicable — instead submit the permissions declaration form describing the single-purpose USSD automation, include a demo video, restrict the service config (`android:packageNames` = carrier dialog) and expect review friction. Fallback if rejected: single-step `sendUssdRequest` flows only + guided manual dialing overlays (app remains fully useful).
- **READ_SMS:** apply under the permitted "financial transaction tracking" use case, declaration form + video. Fallback mode without it must exist and be reviewable.
- **Target API:** current Play requirement at submission time; test API 26 → latest.
- Publish a clear privacy policy URL (rw/en/fr) before submission.

---

## 9. Testing

- Unit: menu-tree runtime against recorded USSD transcripts per provider/version (fixtures updated when configs change).
- Integration: instrumented tests with a fake TelephonyManager; SMS parser against a corpus of real (sanitized) MTN/Airtel/bank messages in all three languages.
- Security tests in CI: log-leak grep, dependency scan, screenshot-flag assertions, backup-off assertion.
- Field protocol: before every release, live-device matrix (MTN low-end, Airtel low-end, dual-SIM) executing one real transaction per flow with 100 RWF amounts.

---

## 10. Release phases & KPIs

1. **Internal (weeks 1-8):** Stages 1-5 on internal track.
2. **Closed beta (weeks 9-12):** 50-100 Kigali users — moto drivers, shop owners, students. KPI: send success rate ≥ 98%, USSD tree-break MTTR < 12 h, crash-free ≥ 99.5%.
3. **Public launch:** consumer free; Merchant mode 2,000-3,000 RWF/month after 30-day trial (MoMo-payable, naturally).
4. **Phase-3 evaluation:** approach RSwitch/BNR about direct eKash API participation only after ≥ 50k MAU and funding for compliance.

North-star metric: weekly successful transactions per active user. Guardrails: misroute rate (target zero), scam-warning save rate, %-transactions completed offline.

---

## 11. Explicit out-of-scope (v1)

Holding funds or wallets, lending/credit scoring, direct eKash API, iOS (until web-dialing research done), crypto, agent/float management, cross-border remittances.
