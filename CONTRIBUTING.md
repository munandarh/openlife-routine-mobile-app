# Contributing

Thanks for your interest in OpenLife Routine. This is the short version — the
full guide is [`docs/contribution-guide.md`](docs/contribution-guide.md).

## Setup

```bash
flutter pub get
dart run build_runner build   # after changing a Drift table
flutter gen-l10n              # after changing an ARB file
flutter run
```

## Validation

Both must be clean before a pull request is reviewed. CI runs exactly these:

```bash
flutter analyze
flutter test
```

## Working rules

- Keep to the MVP scope in [`docs/PRD.md`](docs/PRD.md) §7.
- Full BLoC — do not introduce Cubit.
- No user-facing string literals in widgets: add the key to **both** ARB files
  and read it via `context.l10n`.
- No raw colours, font sizes or paddings in a page: use `lib/core/theme/`.
- A schema change means bumping `schemaVersion` *and* adding the matching
  migration branch, *and* updating `ExportImportService`.
- New screens must pass `test/accessibility/text_scaling_test.dart`.
- Keep `Templates` inside the `Routines` flow for MVP.
- Prefer small, testable changes.

## Reporting

Bugs, features and questions have issue templates in
[`.github/ISSUE_TEMPLATE/`](.github/ISSUE_TEMPLATE). Security issues go through
[`SECURITY.md`](SECURITY.md) instead — please do not open a public issue.
