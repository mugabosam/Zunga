# Zunga — Privacy Policy / Politiki y'Ibanga

*Last updated: 18 July 2026 · Governed by Rwanda Law No. 058/2021 on personal data protection.*

**Icyongereza gusa hano; incamake mu Kinyarwanda:** Zunga ntibika amafaranga yawe, ntibona umubare w'ibanga (PIN) wawe, kandi ntiyohereza amakuru yawe ku byuma byacu. Ibyo ubika byose — nimero, abo wishyuye, urutonde rw'ubwishyu — biguma kuri telefoni yawe gusa. Ushobora kubisiba igihe cyose muri *Profile → Delete my data*.

## What Zunga is

Zunga is a shortcut layer over your own carrier USSD codes. Money moves inside MTN MoMo, Airtel Money or your bank's own session — never through Zunga. We are not a payment service provider and we never hold funds.

## What stays on your phone (and never leaves it)

- **Your registered number** — stored in Android's encrypted secure storage so the app knows which network your payments leave from.
- **Recent recipients and your transaction ledger** — stored in an encrypted local database, only if you keep the "Save" toggles on.
- **Contact name lookups** — performed on the device against your own contact list, only if "Enable contacts" is on. Your contact list is never uploaded.
- **Your carrier or bank PIN** — never touched. You type it into your network's own popup. Zunga cannot see, store or transmit it, and the codebase has an automated check that fails the build if any logging is added to the USSD engine.

## What Zunga sends over the internet

Nothing today. The app works fully offline. If a registered-name lookup service launches in a future version, it will send only the recipient's phone number to resolve the name, over TLS, and this policy will be updated first.

## Your controls

- Every data toggle (contacts, recents, transactions, notifications) is in *Profile* and off means off.
- *Profile → Delete my data* wipes your number, recipients and ledger from the phone immediately. Your carrier accounts are untouched — Zunga never held them.

## Permissions

- **Phone (CALL_PHONE)** — to run the USSD codes you approve, exactly as if you dialed them.
- **Contacts (READ_CONTACTS)** — optional, for recipient name preview only.
- **Phone state (READ_PHONE_STATE)** — to detect which SIMs are in the phone.

## Contact

Questions or requests (access, correction, deletion): open an issue at [github.com/mugabosam/Zunga](https://github.com/mugabosam/Zunga/issues) or use *Profile → WhatsApp support* in the app.
