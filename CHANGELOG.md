# Changelog

All notable changes to OpenLife Routine will be documented in this file.

## [1.1.0] — 2026-09-01

The release that makes the v1.0 feature list true. Several things v1.0 claimed
to ship were wired but not connected; this release connects them, fixes the
data-loss bugs found on the way, and adds the tests that would have caught
them.

### Added
- **Working Indonesian** — the generated `AppLocalizations` delegate is now
  registered on `MaterialApp` and every screen reads through `context.l10n`.
  275 keys across English and Indonesian, covering pages, dialogs, empty
  states, template content and notification copy. Previously the ARB files
  existed but no screen used them, so the language setting changed nothing.
- **Snooze from inside the app** — `TodayRoutineSnoozed` records a snoozed log
  with a wake-up time and re-arms the notification. Snooze was previously only
  reachable from the notification action.
- **`missed` and `snoozed` on the checklist** — both statuses now render, with
  distinct colour tones so a missed routine cannot read like a completed one.
- **A missed-state sweep that catches up** — `sweepMissedDays` closes out every
  day since the last sweep, not just yesterday, bounded by a 30-day lookback
  and resumed from a persisted watermark.
- **Onboarding step 5** — the starter-template picker required by PRD §8.1.
  Picking a template applies it before Today opens; "start empty" is an
  explicit choice.
- **Next-routine card** on Today (PRD §8.2).
- **Icon override** on routines — `iconKey` on the entity, a 13-option picker
  on the form, honoured everywhere a routine icon is drawn.
- **7-day history screen** at `/insights/history`, with per-day done / skipped
  / missed breakdown.
- **Reduce motion** setting, suppressing the celebration overlay.
- **`ApplyTemplateUseCase`** — one path for applying a template, shared by
  onboarding and the Templates screen.
- **Docs** — `architecture.md`, `design-system.md`, `animation-guidelines.md`,
  `contribution-guide.md`, `ROADMAP.md`, question issue template.

### Fixed
- **Notes were lost on edit.** `updateRoutine` never wrote the `notes` column
  and `_mapBundle` never read it, so a note survived creation and vanished on
  the first edit.
- **The snooze slider did nothing.** `snoozeMinutes` was not carried on the
  create or update events, so every routine kept the 10-minute default.
- **Insights over-counted the denominator.** Weekly completion divided by
  `routines × 7`, ignoring repeat days, so a weekdays-only routine could never
  exceed 71%.
- **Skipped routines were reported as missed.** "Most missed" counted every
  non-`done` log; it now counts only `missed`.
- **The streak was always zero.** It broke on today's still-incomplete day; an
  unfinished today no longer ends the streak.
- **Layout overflowed at OS text scales** on the empty states, the language and
  notification screens, and `PrimaryButton`.
- **Card actions were unreachable by screen reader** — the completion circle
  and each action chip are now their own semantics node.
- **Applying a template leaked a BLoC** and could collide on generated ids.
- **Notification copy was hardcoded English** and the snooze notification
  showed the raw routine id instead of its title.
- **Export/import dropped fields** — `iconKey` and `snoozedUntil` are now
  included.

### Fixed — found by running the release build on a device
These only reproduce in a release build or on real hardware, which is why the
test suite did not catch them.
- **Notifications were dead in release builds.** The resource shrinker stripped
  `ic_notification` (it is referenced only by name from Dart), so
  `initialize()` threw `PlatformException(invalid_icon)` and the whole reminder
  stack was disabled. Kept via `res/raw/keep.xml`, and initialization now
  degrades instead of throwing.
- **The onboarding language pick did nothing.** It was written to
  `onboarding.language_code` while `MaterialApp.locale` read
  `settings.language_code`. `SettingsRepository` is now the single owner of the
  language, and the onboarding screens write through `SettingsBloc`.
- **The app was not 16 KB page-size compatible**, which blocks a Play Store
  release for Android 15+. `librive_text.so` from `rive 0.13` was 4 KB aligned;
  upgrading to `rive 0.14` ships a 16 KB-aligned `librive_native.so`.
- **Scheduling threw when the exact-alarm permission was denied**
  (Android 12+, and not granted by default on 14+). It now falls back to an
  inexact alarm instead of failing the create-routine flow.
- **Launcher label read `openlife_routine`** instead of "OpenLife Routine".
- **Action chips took a full row each.** A `Container` with an `alignment`
  expands to the loose width a `Wrap` offers, so Skip and Snooze each claimed
  their own line.
- **The FAB covered the first routine's completion circle** — the offset
  predated the bottom nav moving outside the page's `Stack`.
- **A new routine back-filled the past as missed.** The sweep and Insights now
  ignore days before a routine's `createdAt`, so adding a routine today no
  longer writes 30 days of `missed` logs or zeroes last week's rate.
- **3.7 MB of unused v2.0 artwork shipped in the APK** — `pubspec.yaml`
  registered the whole `assets/vector/` directory.
- **Dark mode was unusable**, despite shipping as a v1.0 feature. Widgets
  referenced `AppColors.textPrimary`/`textSecondary`/`background`/`surface`/
  `border` directly — light-theme constants — in about 140 places, so the dark
  theme painted near-black text on a near-black background: the greeting, the
  whole week strip, routine titles and the navigation labels were all invisible,
  and the app bar stayed cream. `AppTheme.dark()` had only patched the scaffold
  colour afterwards. Surface and text colours now come from an `AppPalette`
  theme extension, and the daily-progress hero has a dark green variant instead
  of a harsh pastel panel.
- **The 7-day history row overflowed in Indonesian** at 320dp: the completion
  count sat in the row at its natural width and "0 dari 3 selesai" is wider than
  its English counterpart.
- **The week strip on Today had the same defect as the Repeat picker.** Six
  40px days plus a 52px selected one need 292px, so the row overflowed a 320dp
  screen by 20px and clipped Sunday out of reach. Both now flex to an equal
  share of the row.
- **The Repeat day picker read as completely dead.** Seven fixed 44px chips
  overflowed a 360dp screen by 20px, which collapsed every gap and clipped
  Sunday out of reach, and `Ink` drew no pill, so the only feedback on tap was a
  faint text-colour change. The chips now flex to a seventh of the row each and
  are real `Material` pills with a filled selected state. Regression tests cover
  320/360/411dp, tapping every weekday including the last, and the fill actually
  changing.
- **Deleting a routine opened from a reminder threw and stranded the user.**
  That screen is entered with `go`, so it has nothing behind it and `pop` threw
  `GoError: There is nothing to pop`; the routine was deleted but the detail
  page stayed on screen. Added `context.popOrGo(...)`, used by Routine Detail
  and the New Routine form.

### Changed
- Database schema v2 → v4 (`RoutineLogs.snoozedUntil`, `Routines.iconKey`).
- Category icons, tints and labels consolidated into `RoutineCategoryUi`;
  weekday and time formatting into `L10nFormatters`.
- `RoutineCard` takes a list of actions and an explicit status tone.
- Greeting helpers return a locale-independent slot resolved through
  localizations, instead of returning hardcoded English or Indonesian strings.
- Onboarding is 4 slides (was 3).
- Privacy and About screens share one `SettingsInfoCard`.
- Empty-state pages scroll instead of centring an unscrollable column.

### Tests
- 188 → **272**, all passing, `flutter analyze` clean.
- New suites: accessibility (text scaling, overflow, tap targets), localization
  coverage (ARB parity, untranslated-copy detection, plurals, version
  constant), missed-state sweep, snooze/missed/next-routine behaviour, insights
  accuracy, routine field persistence, template application, bootstrap.
- Five duplicated settings fakes replaced by one shared
  `FakeSettingsRepository`; `localizedApp()` harness added for localized widget
  tests.

### Changed — build
- `rive` upgraded 0.13 → 0.14 (new `RiveWidgetBuilder` API; the widget still
  falls back to a PNG or an icon when no `.riv` is present or when
  `rive_native` cannot load).
- Release APKs are now built per ABI: 91.4 MB fat APK → 45.3 MB for arm64.

### Added — release engineering
- Release signing reads `android/key.properties` (gitignored) and falls back to
  debug keys with a warning when it is absent, so a clone without the upload key
  still builds. Template in `android/key.properties.example`, procedure in
  `docs/release-guide.md`. Verified by signing a build with a throwaway keystore
  and checking the certificate on the output.

### Verified on device
Release build on an Android 16 emulator: clean launch, working notification
init, language switch, starter template, insights and 7-day history.

The reminder pipeline is now verified end to end rather than assumed:
a routine scheduled for 21:50 fired **at 21:50:00** with the correct title and
body, its Snooze action rescheduled it ten minutes out, tapping it opened that
routine's detail screen, and deleting the routine cancelled every alarm it
owned. Screenshots in `docs/screenshots/`.

### Known gaps
- No `.riv` animation files yet — the app ships PNG illustrations through the
  same wrapper. See `docs/animation-guidelines.md` §4.
- No published store release: the signing config is in place but no upload key
  has been generated, so local builds are still debug-signed.
- iOS compiles but has not been tested on a device.

## [1.0.0] — 2026-07-02

### Added
- **Onboarding** — 4-screen flow (language selection, notification permission, 3 value slides; the starter template picker arrived in 1.1.0)
- **Routine CRUD** — Create, edit, delete, enable/disable routines with 8 categories (meal, water, vitamin, medicine, sleep, exercise, break, custom)
- **Today Checklist** — Daily progress ring, mark done, skip, undo, greeting with supportive subtitle
- **Reminder Engine** — Local notifications with snooze, cancel/update on routine change, timezone-safe scheduling, duplicate prevention
- **Insights** — Weekly completion rate, daily chart, most completed/missed routine, streak calculation
- **Templates** — 5 seed templates (Morning Routine, Hydration Tracker, Vitamin Routine, Sleep Routine, Programmer Break), one-tap apply
- **Settings** — Theme (System/Light/Dark), Language (English/Indonesian), Export/Import JSON, Reset data, Privacy, About Open Source
- **Animations** — Rive wrapper with PNG fallback, progress ring animation, routine card state transitions, daily complete celebration, haptic feedback
- **Vector Illustrations** — 10 custom illustrations for onboarding, today, templates, insights, celebration
- **Notes Field** — Optional notes on routines (DB schema v2)
- **Snooze Duration** — Configurable snooze with slider in new routine form
- **Missed State** — launch-time job marking yesterday's pending routines as missed (superseded in 1.1.0 by a catch-up sweep)
- **i18n Framework** — EN + ID ARB files with 100+ strings (not yet connected to any screen; wired up in 1.1.0)
- **Tests** — 188 unit + widget + BLoC tests
- **Release APK** — `app-release.apk` (90.8 MB)

### Technical
- **Architecture**: Clean Architecture with feature-first modules
- **State Management**: Full BLoC (no Cubit)
- **Database**: Drift SQLite (schema v2)
- **Navigation**: go_router with deep linking from notification taps
- **DI**: Manual dependency injection via `AppScope` + `AppDependencies`
- **CI**: GitHub Actions (analyze + test)

### Documentation
- `docs/PRD.md`
- `docs/SPRINT-CHECKLIST.md`
- `docs/adr/0001-sprint0-foundation-stack.md`
- `CHANGELOG.md` (this file)
- `SECURITY.md`
- `CONTRIBUTING.md`
- `CODE_OF_CONDUCT.md`

[1.0.0]: https://github.com/munandarh/openlife-routine-mobile-app/releases/tag/v1.0.0
[1.1.0]: https://github.com/munandarh/openlife-routine-mobile-app/releases/tag/v1.1.0
