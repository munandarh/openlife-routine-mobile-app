# Changelog

All notable changes to OpenLife Routine will be documented in this file.

## [1.0.0] — 2026-07-02

### Added
- **Onboarding** — 5-screen flow (language selection, notification permission, 3 value slides, starter template picker)
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
- **Missed State** — EOD job marks yesterday's pending routines as missed
- **i18n Framework** — EN + ID ARB files with 100+ strings, `flutter_localizations` wired
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
- `docs/architecture.md` (from `document-openlife/`)
- `docs/design-system.md` (from `document-openlife/`)
- `docs/animation-guidelines.md` (from `document-openlife/`)
- `docs/adr/0001-sprint0-foundation-stack.md`
- `CHANGELOG.md` (this file)
- `SECURITY.md`
- `CONTRIBUTING.md`
- `CODE_OF_CONDUCT.md`

[1.0.0]: https://github.com/harismunandar/openlife-routine/releases/tag/v1.0.0
