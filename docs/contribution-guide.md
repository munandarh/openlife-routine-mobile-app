# Contribution Guide

Thanks for looking at OpenLife Routine. This is the long-form guide;
[`../CONTRIBUTING.md`](../CONTRIBUTING.md) is the short version.

---

## 1. Getting set up

```bash
git clone https://github.com/munandarh/openlife-routine-mobile-app.git
cd openlife-routine-mobile-app

flutter pub get
dart run build_runner build      # Drift generated code
flutter gen-l10n                 # AppLocalizations from the ARB files

flutter run
```

Requires the Flutter stable channel with Dart SDK ^3.11.

Generated files (`*.g.dart`, `lib/l10n/app_localizations*.dart`) are committed,
so a fresh clone analyzes without running codegen. Re-run the commands above
after changing a Drift table or an ARB file, and commit the result.

---

## 2. Before you open a pull request

```bash
flutter analyze     # must be clean — zero issues, not "zero errors"
flutter test        # must be green
```

CI runs exactly these two. A PR that fails either will not be reviewed until
it is green.

---

## 3. House rules

These are conventions the codebase already follows. Matching them keeps the
diff readable.

**Architecture**

- Feature-first: `features/<name>/{presentation,application,domain,data}`.
- `domain/` imports nothing from Flutter, Drift, or the notification plugin.
- New dependencies are constructed in `AppDependencies`, not looked up ad hoc.

**State**

- Full BLoC. Do not introduce Cubit — see
  [`adr/0004-bloc-over-cubit.md`](adr/0004-bloc-over-cubit.md).
- States are immutable and `Equatable`.
- When null is a meaningful value for a field, give `copyWith` an explicit
  `clearX` flag. `copyWith(x: null)` cannot express "set this to null".

**UI**

- No raw hex colours, font sizes, or paddings in a page. Use
  `lib/core/theme/` tokens.
- Category icons and tints come from `RoutineCategoryUi`.
- Anything drawn on more than one screen belongs in `lib/shared/widgets/`.

**Strings**

- No user-facing literal in a widget. Add the key to **both**
  `lib/l10n/app_en.arb` and `lib/l10n/app_id.arb`, run `flutter gen-l10n`, and
  read it through `context.l10n`.
- `test/l10n/localization_coverage_test.dart` fails if a key is missing from
  one file or if the Indonesian value is still a copy of the English one.
- Do not write your own weekday names or time formatting — use
  `L10nFormatters`.

**Database**

- A schema change means bumping `schemaVersion` **and** adding the matching
  `if (from < n)` branch in `AppDatabase.migration`. A version bump without a
  migration branch crashes existing installs.
- Add the new field to `ExportImportService` in the same change, or a backup
  silently loses it.

**Accessibility**

- Tap targets ≥ 44×44.
- Icon-only controls need a semantic label.
- Any new screen must survive `test/accessibility/text_scaling_test.dart` at
  1.3× and 2.0×.

---

## 4. Writing tests

Put the test next to the layer it covers, mirroring `lib/`.

Use the shared harnesses in `test/support/`:

- `localizedApp(widget, locale: …, textScale: …)` — required for any widget
  that reads `context.l10n`. A bare `MaterialApp` will throw.
- `FakeSettingsRepository` — the one settings fake. Do not add a sixth.
- `AppNotificationService.noop()` — accepts every call, schedules nothing.

Two things that will waste your afternoon otherwise:

- `testWidgets` runs in a fake-async zone. `await`ing a Drift stream in the
  test body hangs forever. Seed the database in `setUp`, and assert through the
  UI.
- Injecting a fixed clock (`nowProvider:`) is how the date-sensitive blocs and
  services are tested. Never let a test depend on the real `DateTime.now()`.

---

## 5. Scope

The MVP scope is defined in [`PRD.md`](PRD.md) §7. Features explicitly out of
scope — accounts, cloud sync, AI coaching, social features, medical claims —
will be closed rather than reviewed, regardless of implementation quality.

If you want to propose something beyond scope, open a discussion first.

---

## 6. Commits and PRs

- One logical change per pull request.
- Present tense, imperative subject: `Add snooze action to Today checklist`.
- Reference the PRD section a change implements when there is one.
- Update `docs/SPRINT-CHECKLIST.md` when a tracked item is completed.
- Fill in the pull request template.

---

## 7. Reporting things

- Bug → `.github/ISSUE_TEMPLATE/bug_report.md`
- Feature idea → `.github/ISSUE_TEMPLATE/feature_request.md`
- Question → `.github/ISSUE_TEMPLATE/question.md`
- Security issue → **do not open an issue**; follow
  [`../SECURITY.md`](../SECURITY.md).
