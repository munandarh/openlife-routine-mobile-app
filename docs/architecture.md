# Architecture

> How OpenLife Routine is put together, and why. Written against the code as it
> actually is — if this file and `lib/` disagree, the code wins and this file is
> a bug.

---

## 1. Shape of the project

```text
lib/
├── app/                  # Composition root: app widget, router, bootstrap
├── core/                 # Cross-feature infrastructure
│   ├── app_info.dart     # Version + repo constants (asserted against pubspec)
│   ├── di/               # AppDependencies + AppScope (manual DI)
│   ├── localization/     # Locale list, context.l10n extension, formatters
│   ├── notifications/    # AppNotificationService (flutter_local_notifications)
│   ├── services/         # HapticService
│   ├── storage/          # Drift database + generated code
│   └── theme/            # Design tokens + ThemeData
├── features/             # Feature-first modules
│   ├── onboarding/
│   ├── today/
│   ├── routines/
│   ├── routine_detail/
│   ├── insights/
│   ├── templates/
│   ├── settings/
│   └── splash/
├── l10n/                 # ARB sources + generated AppLocalizations
├── shared/               # Reusable widgets, illustrations, navigation
└── main.dart
```

Each feature owns up to four layers. Not every feature needs all four — the
Today feature has no repository of its own because it reads the shared database
directly through its BLoC.

| Layer | Holds | Depends on |
|---|---|---|
| `presentation/` | Pages, widgets, BLoC | application + domain |
| `domain/` | Entities, repository interfaces, use cases | nothing outside domain |
| `data/` | Repository implementations, data sources, mappers | domain |

The dependency rule is one-way: `presentation → domain ← data`. Nothing in
`domain/` imports Flutter widgets, Drift, or `flutter_local_notifications`.

---

## 2. Composition root

There is no service locator package. Dependencies are built once in
`AppDependencies.bootstrap()` and handed down the tree by `AppScope`, an
`InheritedWidget`.

```text
main()
 └─ bootstrap()                       lib/app/bootstrap.dart
     ├─ AppDependencies.bootstrap()   opens DB, initializes notifications
     ├─ closeOutPastDays()            missed-state sweep (see §6)
     └─ runApp(OpenLifeApp)
         └─ AppScope                  exposes AppDependencies
             └─ BlocProvider<SettingsBloc>
                 └─ MaterialApp.router
```

Feature BLoCs are created by factory methods on `AppDependencies`
(`createTodayBloc()`, `createRoutineBloc()`, …) and provided per-route. This
keeps construction in one file while letting each page own its BLoC lifetime.

**Why manual DI:** the graph is small and entirely known at startup. A DI
package would add a dependency and a layer of indirection without removing any
real work. See [`adr/0001-sprint0-foundation-stack.md`](adr/0001-sprint0-foundation-stack.md).

---

## 3. State management

Full BLoC, no Cubit — see [`adr/0004-bloc-over-cubit.md`](adr/0004-bloc-over-cubit.md).

| BLoC | Owns |
|---|---|
| `OnboardingBloc` | Slide index, language pick, starter-template pick |
| `TodayBloc` | Selected date, checklist items, done/skip/snooze |
| `RoutineBloc` | Routine list stream + create/update/delete |
| `TemplateBloc` | Seed template list |
| `InsightsBloc` | Weekly metrics, streak, 7-day history |
| `SettingsBloc` | Theme, language, reduced motion |

States are `Equatable` and immutable; every state exposes a `copyWith` with
explicit `clearX` flags where null is a meaningful value (clearing a note,
clearing a template pick). Without those flags `copyWith(x: null)` is
indistinguishable from "leave x alone", which is how a cleared field silently
survives an edit.

---

## 4. Persistence

Drift over SQLite — see [`adr/0002-choose-drift-over-sqflite.md`](adr/0002-choose-drift-over-sqflite.md).

### Tables

| Table | Purpose |
|---|---|
| `Routines` | Identity: title, category, icon override, notes, enabled flag |
| `RoutineSchedules` | When it fires: reminder time, repeat days, snooze minutes |
| `RoutineLogs` | What happened on a given day: status + snooze wake-up time |

A routine and its schedule are one-to-one; they are split so that changing a
time does not rewrite the routine row, and so the notification layer can read
schedules without loading routine content.

### Schema history

| Version | Change |
|---|---|
| 1 | Initial three tables |
| 2 | `Routines.notes` |
| 3 | `RoutineLogs.snoozedUntil` |
| 4 | `Routines.iconKey` |

Migrations are additive `addColumn` steps in `AppDatabase.migration`. Every
bump needs a matching `if (from < n)` branch — an omitted branch upgrades the
version number without the column and crashes on first query.

### Log statuses

`done` · `skipped` · `missed` · `snoozed`

There is deliberately no `pending` row. Pending is the *absence* of a log for a
scheduled day, which means the common case writes nothing at all, and a day
with no rows is unambiguous.

---

## 5. Reminders

`AppNotificationService` wraps `flutter_local_notifications` and owns all
scheduling.

- One notification id per (routine, weekday), derived from a stable hash of the
  routine id, so rescheduling replaces rather than duplicates.
- Weekday slots 1–7 belong to the recurring schedule; slot 99 is reserved for a
  one-off snooze, so re-arming a snooze never cancels a weekly reminder.
- Payload is `routineId|snoozeMinutes|title`. The title rides along so the
  snooze notification can name the routine without a database round-trip, and
  the parser still accepts the older two-field form.
- Schedules are rebuilt from the database on every launch
  (`syncRoutineSchedules`), which is the recovery path after a reboot, a
  timezone change, or an OS that dropped pending alarms.
- The service is built outside any widget tree, so it holds its own copy of the
  active language (`setLanguageCode`) and resolves notification copy through
  `AppLocalizations.delegate.load()`.

`AppNotificationService.noop()` is the constructor tests use: it accepts every
call and schedules nothing.

---

## 6. Daily lifecycle

A routine that is never answered has to become `missed` once its day is over
(PRD §8.5). There is no background worker in the MVP, so the work happens at
launch:

```text
closeOutPastDays()                      lib/app/bootstrap.dart
 └─ MissedStateService.sweepMissedDays(since: lastSweepDate)
     for each day from lastSweep+1 .. yesterday
       for each enabled routine repeating on that weekday
         if no done/skipped/missed log exists → write `missed`
```

Three properties matter:

- **It catches up.** The cursor starts at the last recorded sweep, not at
  yesterday, so a phone that did not open the app for a week still closes out
  all seven days.
- **It is bounded.** `maxLookbackDays` (default 30) caps a first run so a stale
  install does not write a year of rows on launch.
- **It records yesterday as the watermark**, not today. Recording today would
  make tomorrow's run skip today forever.

`TodayBloc` also *derives* `missed` for a past day that has no log yet, so the
UI is correct even before the sweep has written the row.

---

## 7. Localization

- Sources: `lib/l10n/app_en.arb` (template) and `app_id.arb`.
- Generated by `flutter gen-l10n` into `lib/l10n/app_localizations*.dart`,
  configured by `l10n.yaml`. The generated files are committed so a fresh clone
  analyzes without a codegen step.
- Access is through `context.l10n` (`core/localization/l10n_extensions.dart`).
- `L10nFormatters` centralises weekday names, repeat-day lists, and `HH:mm`
  parsing/formatting so the device's 12/24-hour preference is honoured
  everywhere.
- Content that lives in the domain layer (template names, routine names inside
  a template) is stored as stable keys plus an English fallback and resolved in
  presentation by `TemplateL10n`.

`test/l10n/localization_coverage_test.dart` fails the build if a key exists in
one ARB but not the other, or if an Indonesian value is still a copy of the
English one.

---

## 8. Navigation

`go_router`, declared in `lib/app/router/app_router.dart`. Four tabs sit inside
`OpenLifeShell`; everything else is a full-screen push.

```text
/splash
/onboarding/language-selection
/onboarding/notification-permission
/onboarding
/today            ┐
/routines         │ bottom navigation (OpenLifeShell)
/insights         │
/settings         ┘
/routines/templates
/routines/new           ?id= for edit
/routines/detail        ?id=
/insights/history
/settings/privacy
/settings/about
```

Tapping a reminder emits the routine id on
`AppNotificationService.routineTapStream`; `OpenLifeApp` listens and routes to
`/routines/detail?id=…`. A notification that launched the app cold is handled
separately, via `initialNotificationRoutineId` on the splash screen.

---

## 9. Testing

| Kind | Where | What it covers |
|---|---|---|
| Domain/unit | `test/features/**/domain` | Sweep logic, use cases, entities |
| BLoC | `test/features/**/bloc` | Event → state, including edge cases |
| Data | `test/features/routines/data` | Round-trip persistence of every field |
| Widget | `test/features/**/pages`, `test/shared` | Rendering and wiring |
| Accessibility | `test/accessibility` | Text scaling, overflow, tap targets |
| Localization | `test/l10n` | ARB parity, plurals, version constants |

Shared harnesses live in `test/support/`:

- `localizedApp()` — a `MaterialApp` carrying the generated delegates, with an
  optional locale and text scale. Any widget reading `context.l10n` must be
  pumped through it.
- `FakeSettingsRepository` — one in-memory settings fake for every suite.

Two gotchas worth knowing:

- `testWidgets` runs in a fake-async zone. Awaiting a Drift stream directly in
  a test body hangs; assert through the UI, or do database work in `setUp`.
- Widget tests are the overflow guard. `tester.takeException()` after pumping
  at a large `textScale` is what caught the layout bugs the accessibility suite
  now protects.

CI (`.github/workflows/flutter_ci.yml`) runs `flutter analyze` and
`flutter test` on every push and pull request.

---

## 10. Deliberate limits

- **No background scheduler.** Missed-state runs at launch. A `WorkManager`
  job would be more precise and is out of MVP scope.
- **No cloud, no account.** The database is the only source of truth and it
  never leaves the device. Backup is a manual JSON export.
- **No `.riv` files yet.** `OpenLifeRiveView` has the Rive path wired but ships
  PNG illustrations; see [`animation-guidelines.md`](animation-guidelines.md).
- **Android first.** iOS builds but has had no device testing.
