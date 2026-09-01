# OpenLife Routine — Master Checklist

> **Purpose:** single source of truth for what is done and what is still pending
> relative to [`PRD.md`](PRD.md).
> **Source of truth:** `docs/PRD.md` (v1.0) — Milestones 1–6 + Definition of Done.
> **Rule:** an item is only `[x]` if it is verifiable in the code or by a test.
> If this file and the code disagree, the code wins and this file is a bug.

---

## Legend

- `[x]` done and verified
- `[/]` partially done — the gap is stated inline
- `[ ]` not started
- `[—]` cannot be done from a code change alone (needs a device, an account, or artwork)

---

## Status snapshot

| Metric | Value |
|---|---|
| App version | 1.1.0+2 |
| `flutter analyze` | 0 issues |
| `flutter test` | **275 passing** |
| Database schema | v4 |
| Localized strings | 275 keys × EN/ID |
| Illustrations wired | 10 PNG / 10 MVP |
| Rive `.riv` files | 0 / 6 |
| Release APK (arm64) | 45.3 MB, verified on Android 16 |

---

## P0 — Core MVP

### Foundation (PRD §15, M1)

- [x] Flutter project with Clean Architecture, feature-first modules
- [x] Design tokens + light/dark theme
- [x] `go_router` navigation
- [x] Localization generated from ARB and **wired into the app**
- [x] Lint rules + analysis options (clean)
- [x] GitHub Actions CI (analyze + test)
- [x] ADRs 0001–0006

### Onboarding (PRD §8.1, M1) — 5 screens

- [x] Language selection
- [x] Notification permission (dedicated screen with rationale + request CTA)
- [x] Welcome / value slide
- [x] Routine benefit slide
- [x] Privacy-first slide
- [x] **Starter template picker** — 4th slide; the pick applies before Today opens, "start empty" is explicit

### Routine creation (PRD §8.3, §13.1, M2)

- [x] Name
- [x] Category (8 values)
- [x] Time picker (honours device 12/24h)
- [x] Repeat days
- [x] Notes — persisted on create **and update**
- [x] Snooze duration — the slider value is actually saved
- [x] Icon override — `iconKey` on the entity + 13-option picker
- [x] Active flag
- [x] Client-side validation with localized messages

### Today screen (PRD §8.2, M3)

- [x] Time-of-day greeting with supportive subtitle
- [x] Daily progress ring
- [x] **Next routine card**
- [x] Week date selector
- [x] Routine list
- [x] Mark done / undo
- [x] Skip
- [x] **Snooze from inside the app**
- [x] Empty state
- [x] Quick add (FAB)

### Daily checklist statuses (PRD §8.5)

- [x] Pending
- [x] Done
- [x] Skipped
- [x] **Snoozed** — with wake-up time shown on the card
- [x] **Missed** — rendered with its own colour tone
- [x] Daily reset (instances derived from schedules)
- [x] **End-of-day close-out** — catch-up sweep from the last watermark, bounded to 30 days ([ADR 0006](adr/0006-launch-time-missed-sweep.md))

### Reminder engine (PRD §8.4, M4)

- [x] Permission request flow
- [x] Weekly local scheduling
- [x] Cancel / reschedule on routine change
- [x] Rebuild all schedules on launch
- [x] Timezone handling
- [x] Duplicate prevention (stable id per routine × weekday)
- [x] Notification tap opens the routine
- [x] Snooze action + dedicated snooze slot
- [x] **Localized notification copy** (title, body, action label)

### Local database (PRD §13.3, M2)

- [x] Routines / RoutineSchedules / RoutineLogs
- [x] Migrations v1 → v4, each with a migration branch
- [x] Daily instances derived from active routines
- [x] Historical logs retained

### Progress calculation (PRD §13.4, M3)

- [x] Total / completed / pending / skipped / missed / snoozed counts
- [x] Completion percentage
- [x] Weekly rate divided by **scheduled occurrences**, not routines × 7

### Settings (PRD §13.5, M1)

- [x] Theme (system / light / dark)
- [x] Language (EN / ID) — takes effect immediately, including notifications
- [x] Notification permission entry point
- [x] Reduce motion
- [x] Export / import JSON (all fields, including `iconKey` and `snoozedUntil`)
- [x] Reset all data
- [x] Privacy screen
- [x] About screen (version asserted against `pubspec.yaml` by a test)

### Privacy (PRD §14.3)

- [x] No account
- [x] No third-party analytics
- [x] No tracking
- [x] User-controlled export / reset

---

## P1 — Enhancements

### Templates (PRD §8.7)

- [x] 5 seed templates
- [x] Template list UI
- [x] One-tap apply via a shared `ApplyTemplateUseCase`
- [x] Localized template names and routine names
- [x] No medical claims in copy

### Insights & history (PRD §8.6)

- [x] Weekly completion rate
- [x] Daily bar chart
- [x] Streak (an unfinished today does not break it)
- [x] Most completed routine, with title
- [x] Most missed routine — counts only `missed`, not `skipped`
- [x] **7-day history screen** with per-day done / skipped / missed

### Import / export (PRD §14.2)

- [x] Export JSON
- [x] Import JSON
- [x] Reset

### Theming & language (PRD §10.2, §10.3)

- [x] Light theme
- [x] Dark theme
- [x] **Full English + Indonesian across every screen**

---

## P2 — Open-source repository (PRD §17)

### Required files

- [x] `README.md`
- [x] `LICENSE` (Apache 2.0)
- [x] `CONTRIBUTING.md`
- [x] `CODE_OF_CONDUCT.md`
- [x] `CHANGELOG.md`
- [x] `SECURITY.md`
- [x] `ROADMAP.md`
- [x] `docs/PRD.md`
- [x] `docs/architecture.md`
- [x] `docs/design-system.md`
- [x] `docs/animation-guidelines.md`
- [x] `docs/contribution-guide.md`
- [x] `docs/release-guide.md`
- [x] `docs/adr/` — 6 ADRs

### GitHub templates

- [x] `PULL_REQUEST_TEMPLATE.md`
- [x] `ISSUE_TEMPLATE/bug_report.md`
- [x] `ISSUE_TEMPLATE/feature_request.md`
- [x] `ISSUE_TEMPLATE/question.md`

### README quality (PRD §17.2)

- [x] Product description, features, tech stack, architecture
- [x] How to run + testing commands
- [x] Roadmap, contribution, license
- [x] Badges (CI, license, Flutter, tests, platform)
- [x] Correct repository URLs
- [x] **Screenshots** — `docs/screenshots/`, captured from the release build
- [—] **Demo GIF / video** — needs a screen recording
- [ ] Support / donation link

---

## P3 — Quality

### Accessibility (PRD §14.4)

- [x] Tap targets ≥ 44×44, asserted by test
- [x] Text scaling to 2.0× on every screen, asserted by test
- [x] Semantic labels on icon-only controls
- [x] Card actions are individually focusable
- [x] Status conveyed by words, not colour alone
- [x] Reduced-motion setting
- [ ] Screen-reader pass on a physical device

### Performance (PRD §14.1)

- [x] Insights loads via one range query instead of per-day queries
- [x] No indefinite loops on content screens
- [x] Assets trimmed: unused v2.0 artwork removed from the bundle
- [x] 16 KB page-size compatible (Play Store requirement for Android 15+)
- [—] Frame-rate profiling on a mid-range Android device
- [—] 100-routine load test on hardware

### Release build verification

Run against `app-arm64-v8a-release.apk` on an Android 16 emulator:

- [x] Installs and launches with no exceptions in logcat
- [x] Notifications initialize (the release shrinker used to strip
      `ic_notification`, which threw `PlatformException(invalid_icon)`)
- [x] No 16 KB ELF-alignment warning
- [x] Launcher label reads "OpenLife Routine"
- [x] Language pick in onboarding actually translates the app
- [x] Starter template applies and lands on a populated Today
- [x] Snooze from the checklist shows "Snoozed until HH:MM"
- [x] Insights + 7-day history render with correct data
- [x] Language switch in Settings re-renders the whole app
- [x] **A reminder fires at its scheduled time** — a routine set for 21:50 posted
      at 21:50:00 with the right title and body
- [x] The notification's Snooze action reschedules it ten minutes out
- [x] Tapping a reminder opens that routine's detail screen
- [x] Deleting a routine cancels every alarm it owned
- [x] Release signing verified by building with a throwaway keystore and
      checking the certificate on the output APK
- [ ] Screen-reader pass

### Testing (PRD §14.5)

- [x] Domain / use-case tests
- [x] BLoC tests for every BLoC
- [x] Data-layer round-trip tests for every persisted field
- [x] Widget tests for shared widgets and critical flows
- [x] Accessibility suite
- [x] Localization parity suite
- [x] Onboarding → template → Today end-to-end widget test
- [ ] `integration_test` package run on a device

---

## Remaining before a public release

Everything below needs something a code change cannot provide.

| # | Item | Blocked on |
|---|---|---|
| 1 | Six `.riv` animation files | Artwork authored in the Rive editor. Wiring is done; see `animation-guidelines.md` §4 |
| 2 | Demo GIF / video | A screen recording |
| 3 | GitHub Release with the signed APK | Generating the upload key — the config and procedure are ready (`docs/release-guide.md`) |
| 4 | Play Store listing | A developer account |
| 5 | Device QA — notifications on OEM Android, screen reader, frame rate | Physical hardware |
| 6 | Support / donation link | A funding account |

---

## Out of scope (PRD §7.2) — do not build

Login/register · cloud sync · AI coach · family mode · web dashboard ·
subscription · B2B dashboard · medical diagnosis · smartwatch · push server ·
social features · community feed

---

## Illustration asset map (`assets/vector/`)

| File | Used by | Status |
|---|---|---|
| `onboarding_build_better_days.png` | Onboarding slide 1 | wired |
| `onboarding_smart_routines.png` | Onboarding slide 2 | wired |
| `onboarding_private_by_default.png` | Onboarding slide 3 | wired |
| `onboarding_starter_template.png` | Onboarding slide 4 | wired |
| `today_notification_bell.png` | Today empty state | wired |
| `today_sleep_routine.png` | Sleep template card | wired |
| `today_water_hydration.png` | Hydration template card | wired |
| `today_vitamin_routine.png` | Vitamin template card | wired |
| `today_daily_celebration.png` | All-done overlay | wired |
| `today_insights_workspace.png` | Insights hero + empty state | wired |
| `future_family_care_*.png` | v2.0 family mode | not bundled |
