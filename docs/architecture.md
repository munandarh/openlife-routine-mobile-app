# Architecture — OpenLife Routine

> Companion to [`PRD.md`](PRD.md). This document describes how the app is
> actually built, not how it might be. Every path and class name below exists
> in `lib/`.

---

## 1. Shape of the app

OpenLife Routine is a single-module Flutter app with no backend. Everything —
routines, schedules, logs, preferences — lives in a local SQLite database on
the device. There is no network layer, no auth, and no remote configuration,
which is a product decision (PRD §6.1, §6.2) rather than a stage the project
has not reached yet.

```
lib/
├── app/            App root, bootstrap, router
├── core/           Cross-feature infrastructure
│   ├── di/         Dependency container and InheritedWidget scope
│   ├── localization/
│   ├── notifications/
│   ├── services/
│   ├── storage/    Drift database
│   └── theme/      Colors, spacing, radius, shadows, text styles
├── features/       One directory per feature, each Clean-Architecture layered
├── l10n/           ARB files and generated AppLocalizations
└── shared/         Widgets, illustrations and navigation used by 2+ features
```

## 2. Clean Architecture per feature

Each feature under `lib/features/` owns its three layers. `routines` is the
reference implementation:

```
features/routines/
├── domain/
│   ├── entities/       Routine, RoutineSchedule — immutable, Equatable
│   ├── repositories/   RoutineRepository — an abstract contract
│   └── usecases/       CreateRoutineUseCase, WatchRoutinesUseCase, …
├── data/
│   ├── datasources/    RoutineLocalDataSource — talks to Drift
│   └── repositories/   DriftRoutineRepository — implements the contract
└── presentation/
    ├── bloc/           RoutineBloc + events + states
    └── pages/          Widgets only
```

The dependency rule points inward: `presentation` depends on `domain`, `data`
implements `domain`, and `domain` depends on nothing but Dart and Equatable.
A page never imports Drift; a use case never imports Flutter.

Not every feature needs all three layers. `templates` has a domain layer with
seed data and no data layer, because its templates are compile-time constants.
`splash` is presentation only.

### Features

| Feature | Responsibility |
|---|---|
| `onboarding` | First-run flow: language, notification permission, 4 value slides, starter template |
| `today` | Daily checklist, progress, greeting, missed-state service |
| `routines` | Routine CRUD, routine list, template application |
| `routine_detail` | Single routine view |
| `templates` | Five seed starter templates |
| `insights` | 7-day completion, streak, weekly chart |
| `settings` | Theme, language, notification permission, export/import, reset, privacy, about |
| `splash` | Decides first-run vs. returning user |

## 3. State management — BLoC

`flutter_bloc` with one BLoC per feature surface. The choice over Cubit is
recorded in [ADR 0004](adr/0004-bloc-over-cubit.md): explicit event objects
give a replayable, testable audit of what the user did.

| BLoC | Drives |
|---|---|
| `OnboardingBloc` | Slide index, language choice, starter template selection |
| `TodayBloc` | Selected date, routine items, done/skip/snooze, progress counts |
| `RoutineBloc` | Routine list stream, create/update/delete |
| `TemplateBloc` | Template list |
| `InsightsBloc` | Weekly completion, streak, most completed/missed |
| `SettingsBloc` | Theme mode and language code |

BLoCs are constructed by `AppDependencies` factory methods
(`createTodayBloc()`, `createRoutineBloc()`, …) and provided per page, not
globally — except `SettingsBloc`, which is held by `OpenLifeApp` because
theme and locale are app-wide.

## 4. Dependency injection

There is no DI package. `AppDependencies` (`core/di/app_dependencies.dart`) is
a plain container built once in `bootstrap()` and handed down through
`AppScope`, an `InheritedWidget`. Pages read it with
`AppScope.read(context)`.

```dart
Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  final AppDependencies dependencies = await AppDependencies.bootstrap();
  unawaited(
    MissedStateService(appDatabase: dependencies.appDatabase)
        .markYesterdayPendingAsMissed(),
  );
  runApp(OpenLifeApp(dependencies: dependencies));
}
```

This keeps wiring greppable and keeps tests honest: a widget test constructs
`AppDependencies` with fakes and passes it to `OpenLifeApp`, with no global
service locator to reset between tests.

## 5. Persistence — Drift

`core/storage/app_database.dart` defines three tables. See
[ADR 0002](adr/0002-choose-drift-over-sqflite.md) for why Drift over raw
sqflite.

| Table | Holds |
|---|---|
| `Routines` | id, title, category, notes, isEnabled, timestamps |
| `RoutineSchedules` | reminderTime, repeatDays (JSON array), snoozeMinutes |
| `RoutineLogs` | one row per routine per day, with a status string |

A routine and its schedule are read together as a `RoutineBundleRow`.

**Log status** is a string with five values: `pending`, `done`, `skipped`,
`snoozed`, `missed` (PRD §8.5). The UI mirrors it as
`TodayRoutineItemStatus`. Keep the two in sync — an unmapped status silently
degrades to `pending`.

**Schema version 2.** Migrations live in `MigrationStrategy`:

| Version | Change |
|---|---|
| 1 | Initial schema |
| 2 | `Routines.notes` added |

Adding a column means bumping `schemaVersion` and extending `onUpgrade`.
Existing installs must survive the upgrade — there is no cloud copy to restore
from.

## 6. Navigation

`go_router`, configured in `app/router/app_router.dart`. Routes are declared
as an `OpenLifeRoute` enum carrying path, label and icon, so the shell's
navigation bar and the router read from one source.

```
/splash → /onboarding/language-selection → /onboarding/notification-permission
        → /onboarding → /today
```

Returning users go straight to `/today`. The four tab destinations
(`/today`, `/routines`, `/insights`, `/settings`) are wrapped in
`OpenLifeShell`. A notification tap pushes `/routines/detail?id=…` through a
stream subscription in `OpenLifeApp`.

## 7. Notifications

`core/notifications/app_notification_service.dart` wraps
`flutter_local_notifications`.

- **Scheduling.** `scheduleRoutine()` cancels the routine's existing
  notifications and schedules one weekly repeat per active weekday, using
  `matchDateTimeComponents: dayOfWeekAndTime`.
- **Ids.** `_notificationId(routineId, weekday)` derives a stable id per
  routine per weekday, which is what makes cancel-and-reschedule idempotent
  and prevents duplicates. Weekday `99` is reserved for the one-off snooze.
- **Snooze.** `scheduleSnooze()` is shared by the notification's Snooze action
  and the in-app Snooze control on Today, so both paths behave identically.
- **Timezone.** `timezone` is initialised at startup and the device zone is
  read over a platform channel, falling back to the package default.
- **Tap handling.** Taps push the routine id onto `routineTapStream`.
- **Tests.** `AppNotificationService.noop()` disables every side effect, so
  tests never touch the plugin.

## 8. Localization

ARB files in `lib/l10n/` (`app_en.arb`, `app_id.arb`) generate
`AppLocalizations` via `flutter gen-l10n`, configured by `l10n.yaml`. The
generated files are committed.

`AppLocalizations.delegate` must stay in `MaterialApp.localizationsDelegates`
— it was missing for several sprints, which made `AppLocalizations.of(context)`
return null and left every screen on hardcoded English. Widget tests that pump
a page directly need `AppLocalizations.localizationsDelegates` on their own
`MaterialApp`, or the page throws.

To add a string: add the key to **both** ARB files, run `flutter gen-l10n`,
then use `AppLocalizations.of(context)!`.

## 9. Theming

`core/theme/` holds the tokens — `AppColors`, `AppSpacing`, `AppRadius`,
`AppShadows`, `AppTextStyles` — and `AppTheme.light()` / `AppTheme.dark()`
assemble them into `ThemeData`. Widgets use the tokens directly rather than
literal values. Theme mode is persisted by `SettingsBloc`.

## 10. Illustrations and animation

`OpenLifeRiveView` (`shared/widgets/rive/`) is the single entry point for
artwork, with three layers in priority order: a Rive `.riv` animation, a static
PNG from `assets/vector/`, and an icon fallback. Named constructors select the
layer: `.asset()`, `.illustration()`, `.illustrationFill()`.

`AssetVectors` (`shared/illustrations/asset_vectors.dart`) is the registry of
bundled PNGs; nothing should hardcode an asset path.

See [ADR 0003](adr/0003-choose-rive-for-animation.md) for the Rive decision and
[`animation-guidelines.md`](animation-guidelines.md) for when motion is
appropriate.

## 11. Testing

`flutter test` runs everything under `test/`, mirroring the `lib/` structure.

| Kind | Approach |
|---|---|
| Domain | Plain unit tests, no Flutter binding |
| Data | Drift on `NativeDatabase.memory()` |
| BLoC | `bloc_test` with an in-memory database |
| Widget | `WidgetTester`, usually pumping `OpenLifeApp` with fake repositories |

CI (`.github/workflows/flutter_ci.yml`) runs `flutter analyze` then
`flutter test` on every pull request. **`flutter analyze` exits non-zero on
info-level lints**, so a style nit fails the build exactly like an error does.

## 12. Constraints worth knowing

- **No background execution.** The end-of-day flip to `missed` runs in
  `bootstrap()` on the next launch, not at midnight. A true end-of-day job
  needs a background worker (PRD §8.5, deferred).
- **CI does not run on `development`.** The workflow triggers on pull requests
  and pushes to `main`, so work pushed straight to `development` is unverified.
- **Log status is a string, not an enum,** at the database boundary. New
  statuses must be added to the mapping in `TodayBloc` as well as the table.
