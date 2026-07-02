# OpenLife Routine — Master Checklist

> **Project:** OpenLife Routine
> **Purpose:** Single source of truth for what's done and what's still pending relative to `docs/PRD.md`.
> **Updated:** Continuously as work progresses.
> **Source of truth:** `docs/PRD.md` (v1.0) — Milestone 1-6 + Definition of Done.

---

## How to Use This File

- `[x]` = completed and verified
- `[ ]` = pending (not started)
- `[/]` = in progress
- Each section maps to a PRD section number for traceability.
- P0 / P1 / P2 priority from PRD §7.1.

---

## Status Snapshot

| Metric | Value |
|---|---|
| Tests passing | **184/184** |
| Flutter analyze | 0 errors, 0 warnings (1 info: deps order) |
| Source files | 88 Dart |
| Test files | 30 |
| Release APK | `build/app/outputs/flutter-apk/app-release.apk` (90.6 MB) |
| Vector assets wired | 10 / 10 MVP (all) |

---

## P0 — Core MVP (Must ship)

### Foundation (PRD §15 + §20 M1)

- [x] Flutter project setup with Clean Architecture
- [x] Theme system (sage green + warm cream)
- [x] Routing with go_router
- [x] Localization foundation (`intl` + 2 locales: `en`, `id`)
- [x] Lint rules + analysis options
- [x] GitHub Actions CI
- [x] ADR scaffolding (`docs/adr/0001-sprint0-foundation-stack.md`)

### Onboarding (PRD §8.1, M1) — 5 screens required

- [x] Welcome screen
- [x] Privacy-first screen
- [x] Routine benefit screen
- [/] **Notification permission request screen** — currently integrated as info panel, needs dedicated screen with rationale + request CTA
- [ ] **Choose starter template or start empty screen** — not implemented; first-run after notification permission currently goes straight to Today

### Routine Creation (PRD §8.3 + §13.1, M2)

- [x] Name (TextField)
- [x] Category (Enum: meal, water, vitamin, medicine, sleep, exercise, break, custom)
- [x] Time (TimePicker)
- [x] Repeat (RepeatRule)
- [x] Snooze duration (default 10)
- [x] Active (bool, default true)
- [x] **Notes field** — entity + DB schema v2 + BLoC events + export/import + new routine form UI
- [/] **Icon override (Enum/SVG, default by category)** — `iconKey` exists in entity but no UI picker

### Today Screen (PRD §8.2, M3)

- [x] Daily progress ring
- [x] List of today routines
- [x] Quick add button (FAB)
- [x] Empty state if no routine
- [x] Mark as done
- [x] Skip routine
- [x] **Greeting component** ("Good morning", etc.)
- [x] **Next routine card** — greeting now shows supportive subtitle based on progress state
- [x] **Missed status** — `MissedStateService.markYesterdayPendingAsMissed()` wired into `bootstrap()`

### Daily Checklist (PRD §8.5, M3)

- [x] Pending, Done, Skipped statuses
- [/] **Snoozed status** — service supports snooze action; UI status enum exists but RoutineCard doesn't render "Snoozed" badge
- [ ] **Missed status** — end-of-day job not implemented; PRD requires routines that aren't completed by EOD to flip to `missed`

### Reminder Engine (PRD §8.4, M4)

- [x] Local notification scheduling
- [x] Snooze basic
- [x] Notification permission flow
- [x] Cancel/update on routine change
- [x] Timezone handling
- [x] Duplicate prevention
- [x] Rebuild schedules on restart
- [x] Notification tap opens relevant routine

### Local Database (PRD §13.3, M2)

- [x] Routines table
- [x] RoutineSchedules table
- [x] RoutineLogs table
- [x] Generate daily instances from active routines
- [x] Reset daily checklist
- [x] Maintain historical logs

### Progress Calculation (PRD §13.4, M3)

- [x] Total routines today
- [x] Completed routines
- [x] Pending routines
- [x] Skipped routines
- [x] **Missed routines** — `MissedStateService` marks yesterday's pending → missed on bootstrap
- [x] Completion percentage

### Settings (PRD §13.5, M1)

- [x] Theme selection
- [x] Language selection
- [x] Notification permission status
- [x] Backup/export (JSON)
- [x] Privacy information
- [x] About / open-source links

### Animations (PRD §11, M5)

- [x] Shared Rive wrapper with static fallback
- [x] Onboarding animation integration (fallback)
- [x] Empty state animation
- [x] Done check animation
- [x] Daily complete animation
- [x] Progress ring animation
- [x] Haptic feedback
- [ ] **Real Rive `.riv` assets** — wrapper is in place; need to ship actual `.riv` files
- [ ] **Vector illustrations integration** — 14 PNGs in `assets/vector/` need to be wired into the app

### Privacy (PRD §14.3)

- [x] No account required
- [x] No third-party analytics
- [x] No user data selling
- [x] Export/import controlled by user
- [x] Privacy info screen

---

## P1 — Enhancements (Recommended for v1.0)

### Routine Templates (PRD §8.7, v1.1)

- [x] Template model
- [x] 5 seed templates (Morning, Hydration, Vitamin, Sleep, Programmer Break)
- [x] Template list UI
- [x] Apply template flow
- [x] No medical claims in copy

### 7-Day History (PRD §8.6, v1.1)

- [x] Weekly completion rate
- [x] Weekly chart
- [x] Most completed routine
- [x] Most missed routine
- [x] Streak calculation
- [ ] **Last 7-day completion summary screen** — currently a single chart; full history view not implemented

### Import/Export JSON (PRD §14.2)

- [x] Export routines as JSON
- [x] Import routines from JSON
- [x] Backup validation

### Dark Mode (PRD §10.2)

- [x] Light theme
- [x] Dark theme
- [x] User can toggle

### Multi-language (PRD §10.3, v1.1)

- [x] English support
- [/] **Real Indonesian translations** — language switching wired but most UI text is hardcoded English; only `id`/`en` preference persisted

### Reset Data (PRD v1.0)

- [x] Reset all data with confirmation

---

## P2 — Open-Source Repository (PRD §17, M6)

### Required Repo Files

- [x] `README.md`
- [x] `LICENSE` (Apache 2.0)
- [x] `CONTRIBUTING.md`
- [x] `CODE_OF_CONDUCT.md`
- [ ] **`CHANGELOG.md`** — does not exist yet
- [ ] **`SECURITY.md`** — does not exist yet
- [x] `ROADMAP.md` (`document-openlife/roadmap.md`)
- [x] `docs/PRD.md`
- [x] `docs/architecture.md`
- [x] `docs/design-system.md`
- [x] `docs/animation-guidelines.md`
- [ ] **`docs/contribution-guide.md`** — not yet split
- [/] **ADRs (Architecture Decision Records)** — only 1 ADR exists (`0001-sprint0-foundation-stack.md`); need at least:
  - [ ] 0002-choose-drift-over-sqflite.md
  - [ ] 0003-choose-rive-for-animation.md
  - [ ] 0004-offline-first-core.md
  - [ ] 0005-bloc-over-cubit.md

### GitHub Templates

- [x] `.github/PULL_REQUEST_TEMPLATE.md`
- [ ] `.github/ISSUE_TEMPLATE/bug_report.md`
- [ ] `.github/ISSUE_TEMPLATE/feature_request.md`
- [ ] `.github/ISSUE_TEMPLATE/question.md`

### README Quality (PRD §17.2)

- [x] Product description
- [x] Tech stack
- [x] Architecture overview
- [x] How to run
- [x] Testing command
- [/] **Screenshots** — directory `ui-ux-design-screen/` exists with PNGs; need to add real app screenshots
- [ ] **Demo GIF/video** — does not exist
- [x] Contribution guide (in `CONTRIBUTING.md`)
- [x] License
- [ ] **Support / donation link** — placeholder
- [ ] **Badges** (CI, license, version)

---

## P3 — Quality & Polish

### Accessibility (PRD §14.4)

- [x] Tap targets ≥ 44×44
- [x] Color contrast (tested in design system)
- [x] Semantic labels (most widgets)
- [ ] **Text scaling support** — no `MediaQuery.textScaleFactor` test
- [ ] **Reduced-motion setting** — deferred to v1.1
- [ ] **Dynamic text scale test** — no widget test
- [ ] **Icon-only buttons have semantic labels** — partial

### Performance (PRD §14.1)

- [x] 100 routines without lag (Drift pagination not needed at MVP scale)
- [ ] **Performance test on mid-range Android** — manual QA pending
- [ ] **Frame rate test** — not automated

### Architecture Quality (PRD §14.5)

- [x] Clean Architecture
- [x] Clear module boundaries
- [x] Testable business logic
- [x] Documentation

### Testing (PRD §14.2)

- [x] Unit tests for routine logic
- [x] Unit tests for progress logic
- [x] Unit tests for schedule logic
- [x] Unit tests for notification logic
- [x] Bloc tests for all Blocs
- [x] Widget tests for shared widgets
- [x] Widget tests for critical flows (today, onboarding)
- [/] **Integration test for end-to-end create-routine-and-schedule** — only partial
- [x] 80%+ coverage on tested layers

---

## P3 — Portfolio Release (PRD §20 M6, §19.2, §23)

- [x] Release APK built locally
- [ ] **Publish APK to GitHub Releases**
- [ ] **Demo video (or animated GIF)**
- [ ] **Screenshots in README**
- [ ] **Portfolio case study** (LinkedIn post, blog, etc.)
- [ ] **CV / resume updated**

### Open-Source Metrics Targets (3 months, PRD §19.2)

- [ ] 100+ GitHub stars
- [ ] 10+ forks
- [ ] 5+ external issues
- [ ] 3+ external contributors
- [ ] 1 demo video
- [ ] 1 published APK release

---

## Out of Scope (PRD §7.2) — DO NOT BUILD

These are explicitly excluded from MVP and tracked here so we don't accidentally drift:

- Login / register
- Cloud sync
- AI coach
- Family / caregiver mode
- Web dashboard
- Subscription
- B2B clinic dashboard
- Medical diagnosis
- Smartwatch integration
- Push notification server (we use local only)
- Social features
- Community feed

---

## Vector Asset Map (`assets/vector/`)

14 PNGs are ready and have been renamed to semantic names. The mapping below
shows where each asset should be wired into the app. Until `.riv` files
are produced, these PNGs are the static fallback rendered by
`OpenLifeRiveView`.

| File | Target | Status |
|---|---|---|
| `onboarding_build_better_days.png` | Slide 1 hero (welcome) | wired (Sprint 10) |
| `onboarding_smart_routines.png` | Slide 2 hero (reminders) | wired (Sprint 10) |
| `onboarding_private_by_default.png` | Slide 3 hero (privacy) | wired (Sprint 10) |
| `onboarding_starter_template.png` | Slide 4 hero (template picker) | wired (Sprint 11) |
| `onboarding_build_better_days_alt.png` | Drop-in alternative (identical to main) | keep as alt |
| `today_notification_bell.png` | Today empty state + next-routine hero | wired (Sprint 11) |
| `today_sleep_routine.png` | Sleep template card hero | wired (Sprint 11) |
| `today_water_hydration.png` | Hydration template card hero | wired (Sprint 11) |
| `today_vitamin_routine.png` | Vitamin template card hero | wired (Sprint 11) |
| `today_daily_celebration.png` | All-routines-done overlay | wired (Sprint 10) |
| `today_insights_workspace.png` | Insights page hero + empty state | wired (Sprint 11) |
| `future_family_care_white.png` | v2 family care (no bg) | archive |
| `future_family_care_with_bg.png` | v2 family care (with bg) | archive |
| `future_family_care_with_bg_alt.png` | v2 family care alt | archive |

To make these loadable by Flutter, register them under `flutter:` in
`pubspec.yaml` (asset path `assets/vector/`) and create an
`AssetVectors` registry in `lib/shared/illustrations/`.

---

## Tier 1 — Recommended Next (Do First)

These are the **highest-leverage gaps** relative to PRD MVP DoD:

1. **Rive / vector asset integration** — wrapper ready but no real `.riv` files; 14 PNGs in `assets/vector/` are uncommitted and unused.
2. **Onboarding screen 4 (notification permission)** — currently a Slide 2 info panel, needs dedicated request screen.
3. **Onboarding screen 5 (starter template picker)** — entirely missing from first-run flow.
4. **Greeting + Next routine card on Today** — PRD §8.2 requires both, only progress card exists.
5. **Notes field on Routine** — entity lacks the field; PRD §16.1 requires it.
6. **Icon override picker on New Routine** — entity has `iconKey` but no UI.
7. **End-of-day "missed" job** — routine status exists, no logic flips pending to missed at EOD.
8. **Real i18n (full EN + ID translations)** — language switching wired, but strings hardcoded.

## Tier 2 — Repo Readiness

1. `CHANGELOG.md`, `SECURITY.md`, `ROADMAP.md` at repo root
2. `.github/ISSUE_TEMPLATE/*.md`
3. More ADRs (Drift, Rive, BLoC choices)
4. README with screenshots + demo GIF
5. GitHub Release page with APK

## Tier 3 — Portfolio

1. Demo video
2. LinkedIn case study post
3. README polish (badges, hero image)

---

## Sprint Status

| Sprint | Status | Key Deliverable |
|---|---|---|
| **Sprint 0** | ✅ | Project foundation, docs, CI |
| **Sprint 1** | ✅ | Design system, theme tokens, app shell |
| **Sprint 2** | ✅ | 3-page onboarding, first-run persistence |
| **Sprint 3** | ✅ | Routine CRUD, Drift database, RoutineBloc |
| **Sprint 4** | ✅ | Today checklist, TodayBloc, progress calculation |
| **Sprint 5** | ✅ | Notification engine, scheduler, snooze, payload |
| **Sprint 6** | ✅ | Rive wrapper, animations, haptic, celebration |
| **Sprint 7** | ✅ | Templates (5 seed), InsightsBloc, weekly chart |
| **Sprint 8** | ✅ | Settings, theme/lang switch, export/import, privacy, about |
| **Sprint 9** | ✅ | Validation tests, progress edge cases, APK build |
| **Sprint 10** | ✅ | Vector asset integration (4 wired: 3 onboarding slides + today celebration) |
| **Sprint 11** | ✅ | 4th onboarding screen + 6 more illustrations wired (10/10 MVP) |
| **Sprint 13** | ✅ | Notes field (+DB migration) + snooze UI + new routine form polish |

## Sprint Plan Going Forward

| # | Sprint | Focus | ETA |
|---|---|---|---|
| 10 | Asset Integration | Wire 14 vector PNGs, prepare Rive asset plan, asset-driven onboarding Rive | |
| 11 | Onboarding Completion | 5-screen onboarding (notification permission + starter template) | |
| 12 | Today Polish | Greeting + Next routine card + missed-state EOD job | |
| 13 | Form Completeness | Notes field, icon override picker, snooze UI | |
| 14 | Real i18n | Full EN + ID translations via `intl` arb files | |
| 15 | Repo Readiness | CHANGELOG, SECURITY, ISSUE_TEMPLATE, ADRs, README screenshots | |
| 16 | Portfolio Release | Demo video, GitHub release, LinkedIn case study | |

---

## Maintenance Notes

- Update this file as work completes.
- When a section is fully done, the reviewer signs off in commit message.
- Cross-reference PRD section numbers in commits.
- Never commit `assets/vector/ChatGPT Image*.png` raw — rename to semantic names during asset integration.
