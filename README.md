# Rofin — روفن

A private, offline-first money tracker for personal and small-business finances.
Arabic-first with full English support, built with Flutter.

Rofin keeps every record on the device. There is no account, no server, and no
cloud sync.

## Features

- **Personal and business spaces** — separate ledgers with a combined "All"
  view. Moving money between spaces is a transfer (an owner draw), never income.
- **Accounts** — cash, bank, wallet, savings, and credit-style accounts with
  opening balances, archiving, and per-account balances.
- **Transactions** — income, expense, and transfers with bilingual categories,
  notes, dates, and a searchable / filterable history.
- **Budgets** — monthly limits per space and category with live progress.
- **Recurring rules** — automatic due posting on launch plus manual "post now".
- **Reports** — six-month trend, category breakdown, and month-over-month
  comparison.
- **Dashboard** — total balance, monthly income/expenses/net, recent activity,
  budget health, and quick actions.
- **Data portability** — encrypted `.rofin` backups (PBKDF2 + AES-GCM),
  restore with rollback, and UTF-8 CSV export with a BOM for Excel.
- **Privacy** — app lock through the device biometric / PIN / pattern; amounts
  can be hidden from the dashboard.
- **Bilingual UI** — Arabic (default) and English, light / dark / system themes,
  Western digits, and IBM Plex Sans Arabic typography.

## Security and storage

| Concern | Approach |
| --- | --- |
| Database | Hive CE boxes, encrypted with AES-256 |
| Key storage | `flutter_secure_storage` (Android Keystore / libsecret) |
| App lock | `local_auth` using the device credential |
| Backups | PBKDF2-HMAC-SHA256 (210k iterations) + AES-GCM, password never stored |
| Android backup | Disabled (`allowBackup=false`) |

Data lives in the app documents directory (`~/Documents/rofin_*.hive` on Linux
desktop). Losing the device without a backup means losing the data; create
backups from **Settings → Backup & restore**.

## Build and run

Flutter is pinned with [FVM](https://fvm.app) (Flutter 3.50.1). Use `fvm` for
every command.

```bash
fvm install
fvm flutter pub get

# Android
fvm flutter run -d <device>
fvm flutter build apk --release

# Linux desktop (preview; biometrics are bypassed in debug)
fvm flutter run -d linux --debug
```

On Linux, `flutter_secure_storage` needs `libsecret-1`. If the development
headers are missing, point `PKG_CONFIG_PATH` at a local copy before building.

### Android signing

Release builds use the debug key until a keystore is configured. To ship:

```bash
keytool -genkey -v -keystore ~/rofin-upload.jks -keyalg RSA \
  -keysize 2048 -validity 10000 -alias upload
```

Then add `android/key.properties` (never commit it):

```properties
storePassword=...
keyPassword=...
keyAlias=upload
storeFile=/absolute/path/to/rofin-upload.jks
```

and wire a `signingConfig` in `android/app/build.gradle.kts`.

## Quality checks

```bash
fvm flutter gen-l10n
fvm flutter analyze
fvm flutter test
```

The test suite covers money/date/currency helpers, balance and budget math,
backup encryption round-trips, and a smoke test of the app shell.

## Project layout

```
lib/
  app.dart                 app root, themes, locale, lock gate
  router/                  go_router graph and onboarding redirect
  core/
    database/              Hive CE setup, repositories, seed data
    models/                immutable models and enums
    providers/             Riverpod repositories, settings, derived data
    services/              finance, recurring, backup, CSV, references, auth
    theme/                 palette, typography, Material 3 themes
    utils/                 money, dates, currency, localization helpers
    widgets/               shared UI building blocks
  features/                onboarding, dashboard, transactions, accounts,
                           categories, budgets, spaces, reports, recurring,
                           settings, backup, lock
  l10n/                    ARB sources and generated localizations
```

## Notes and limitations

- Spaces and accounts can be archived; deletion is guarded and offers
  archiving when records still reference the item.
- Built-in spaces and categories cannot be deleted, only renamed or archived.
- Recurring rules post when the app opens; there is no background scheduler.
- iOS and macOS runners are not included in this repository yet.
- Biometric unlock is unavailable on Linux; debug builds bypass the lock there.

## License

Application code is provided as-is for the Rofin project. Bundled IBM Plex
fonts are licensed under the SIL Open Font License; see
`assets/fonts/OFL-*.txt`.
