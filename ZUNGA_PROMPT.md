# ZUNGA — Master Execution Prompt

You are building **Zunga**, a production-grade Android-first Flutter fintech app for Rwanda: one app for every payment — MTN MoMo, Airtel Money, bank transfers via eKash, bills, government payments, and money tools. Two reference files are the source of truth: `zunga-ui.html` (design system, 22 screens) and `ZUNGA_BUILD.md` (full architecture, security, stages). This prompt tells you what to build, what to CHANGE from the current UI file, and the rules you may never break.

---

## PART 1 — UI restructure: keypad-first home (change from current design)

The current screen 01 (dashboard with balance card, quick actions, recent activity) is TOO HEAVY for the opening screen. Replace the home with a keypad-first layout — Faranga proved this is the right opening move for this market — while keeping all our depth one tab away.

**New screen 01 — Home (keypad):**
- Top bar: active wallet badge, tappable to switch (MTN MoMo / Airtel / bank account) — shows provider name + masked number (MTN ··903). Right side: small profile avatar.
- Center: giant amount display starting at `0 RWF` (64px Poppins 600, white on the navy card) with the keypad below (1-9, 0, clear, backspace). Exactly our monochrome style: #F6F6FA background, navy #232C63 digits on the keypad, dark navy gradient amount card.
- Bottom action row, two buttons: `Balance` (ghost style — triggers on-demand USSD balance check, never auto-polled) and `Pay` (primary, orange #EE7B3F — enabled once amount > 0).
- Tapping Send with an amount → recipient picker (existing screen 02): recents with RESOLVED names, contacts, manual number entry tab, merchant code tab.
- No balance number displayed on home by default. No transaction feed on home. Calm, instant, thumb-reachable.
- Cold launch to this screen in under 2 seconds on a 2 GB device. Android long-press app shortcuts: "Send money", "Buy electricity", "Check balance".

**Relocations (nothing is deleted, everything moves one level down):**
- Combined balance card + linked wallets overview → top of Activity tab.
- Recent activity feed → Activity tab (it was always its true home).
- Quick actions (Pay bill / Electricity / Airtime) → Pay hub (screen 09) remains the breadth entry point, unchanged.
- Bottom nav unchanged: Home (keypad) · Pay · Activity · Profile.

**Design system rules (REVISED — navy/orange, enforce everywhere):** background #F6F6FA; white #FFFFFF cards with soft shadows (0 8-14px blur, rgba(35,44,99,.12-.16)) — no hairline-only borders; primary navy #232C63 (dark gradient cards #2E3A7C→#232C63, active states, headings, keypad digits); single warm accent #EE7B3F (primary buttons, toggles-on, incoming money, success, detection chips, due hints) with tint #FDEEE4; text ink #232C63, secondary #7A80A0; Poppins typeface (600 headings, 500-600 UI, large amounts 600); IBM Plex Mono for tokens and references; radii 16-28px (larger than before — cards 20-26px, buttons 18px); friendly and professional like a modern neobank, never flat or monochrome. Masked identifiers on every screen (+250 78x ··· xxx, ··8901); Kinyarwanda/English/Français strings externalized from the first commit, Kinyarwanda default when device locale is rw.

**Smart destination routing (new core feature):** after the user enters an amount and taps Pay, a single universal input accepts anything, and Zunga detects the route as they type: 078/079-prefixed 10-digit → MTN MoMo number; 072/073 → Airtel Money (or eKash if paying from a bank); 5-6 digit code → MoMo Pay merchant; EUCL meter-pattern number → electricity token purchase; longer account-style number → bank transfer via eKash with a bank picker; letters → contact search. The detected route always shows as a visible, tappable chip ("Detected: Airtel number — Change") so the user can override; ambiguous inputs show a two-option chooser, never a guess. Remember the last-used route per destination. A "Pay from" wallet switcher (MTN / Airtel / linked bank) sits on the home top bar and inside every money flow.

All other 21 screens stay as designed in `zunga-ui.html`.

---

## PART 2 — The two flaws Zunga must never have (learned from Faranga teardown)

### 2.1 Never record a transaction before it is real
Faranga logs a transfer as "made" at button-press — cancelling the PIN dialog still records it, so its history contains phantoms, retry duplicates, and inflated totals. Zunga's rule:

- Status lifecycle, strictly enforced: `initiated → awaiting_pin → pending_confirmation → confirmed | failed | cancelled`.
- A transaction appears in history, totals, insights, and lifetime stats ONLY at `confirmed`.
- Confirmation sources (no MTN API needed, none exists in this build):
  1. `onReceiveUssdResponse` callback — match provider success strings (all three languages, from the signed menu config).
  2. Carrier confirmation SMS (M-Money / AirtelMoney sender IDs) parsed on-device — amount, name, fee, balance, reference.
  3. Reconcile the two by reference: ONE transaction record, never two.
- PIN dialog cancelled → `cancelled`, hidden from history by default.
- Neither confirmation within ~2 min → show as `pending_confirmation` with a grey "unconfirmed" badge and a "verify" action; auto-resolve when the SMS lands. Honest uncertainty, never fake certainty.

### 2.2 Never show "Unknown" for a counterparty
Name resolution order, all free and on-device:
1. The registered name parsed from the carrier's own USSD confirm step (`name_check_step` in the menu config) — shown in the verify card BEFORE sending (fail closed: if the name step can't be parsed, block the automated send and offer manual dial), and saved with the transaction.
2. The name inside the confirmation SMS (also covers transactions made outside the app).
3. Local contact match (hashed locally, never uploaded).
Cache every resolution (number → name) permanently on-device. A repeat recipient must never render as a bare number or "?" avatar.

---

## PART 3 — Engine and architecture (summary; full detail in ZUNGA_BUILD.md)

- Native Kotlin USSD engine over a platform channel: `TelephonyManager.sendUssdRequest` (API 26+), per-SIM routing for dual-SIM, Accessibility Service scoped ONLY to the carrier USSD dialog for multi-step trees, one session at a time, 30 s step timeout.
- Menu trees are signed remote JSON configs (Ed25519, public key pinned in the binary; reject unsigned or version-rollback), cached in Hive, hot-updatable server-side. NEVER hardcode a carrier or bank menu. `expect_contains` strings in rw/en/fr because USSD language follows the SIM.
- Every automated flow has a visible "Dial myself" manual fallback.
- PIN handoff: pause and let the user type into the carrier's own dialog (Play-approved pattern). Always precede it with the coach mark: "MTN/Airtel will now ask for your PIN in a popup — that popup belongs to your carrier, not Zunga." Detect cancellation, recover gracefully.
- Backend (Supabase + RLS) holds ONLY: signed configs, scam-report aggregates (salted hashes), ikimina/split group metadata, device registrations, PII-free analytics. Never balances, PINs, SMS text, or identified amounts.
- Offline-first: history, billers, groups, schedules all readable with zero connectivity; USSD flows need no data.

---

## PART 4 — Security musts (test every item; full spec §6 of ZUNGA_BUILD.md)

- Carrier/bank PINs: never persisted, never logged, never in analytics or crash breadcrumbs; CI grep gate fails the build on any logger call in `ussd/` or `security/`.
- App PIN: Argon2id-hashed, local only, backoff on failures. Biometrics via Keystore, StrongBox where available.
- All Hive boxes AES-256 encrypted, keys wrapped by Android Keystore. `allowBackup=false`. No financial data in SharedPreferences or external storage.
- TLS pinning with backup pin + remote rotation; cleartext traffic off.
- `FLAG_SECURE` on every screen showing balances, tokens, or PIN entry. Tapjacking protection on confirm buttons. Auto-lock after 60 s background.
- Play Integrity + root detection → warn-and-degrade, not hard-block.
- R8 obfuscation, `--obfuscate --split-debug-info`, locked dependencies, osv-scanner in CI.
- Scam protection: reported-number interstitial before send (Cancel is always the primary action); first send to a new number above 100,000 RWF gets hold-to-confirm.
- Rwanda data law 058/2021: per-capability consent screens (contacts, SMS, accessibility — each with plain-language rw/en/fr explanation and a working no-consent mode), in-app export and delete-account, location off by default.

---

## PART 5 — Build order

Follow ZUNGA_BUILD.md stages 1-10 exactly. Stage 1 ships the security shell + the NEW keypad-first home + complete settings (privacy toggles, notifications, language, Rate/Feedback/Share, WhatsApp support deep link, Privacy Policy, Terms, Delete account, Log out, lifetime stats — confirmed-only). Stage 2 ships the send flow end-to-end with the lifecycle and name verification of Part 2. Do not start a stage before the previous one runs on a real device.

Speed law: the daily send must feel as fast as Faranga's. Depth must never cost speed. A user who only ever sends money should never notice the other screens exist.

Out of scope v1: holding funds, direct eKash/MoMo APIs (requires registered company — future phase), lending, iOS, crypto, cross-border.
