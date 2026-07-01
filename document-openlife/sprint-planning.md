# OpenLife Routine — Sprint Planning

> **Product:** OpenLife Routine  
> **Goal:** Build a polished open-source Flutter portfolio app  
> **Recommended Sprint Length:** 1 week per sprint  
> **Development Style:** Solo-friendly, incremental, demo-ready every sprint  
> **Sprint Planning Version:** v1.0

---

## 1. Sprint Planning Purpose

This document breaks the OpenLife Routine roadmap into focused development sprints.

The plan is designed for a solo Flutter developer who wants to build a serious open-source portfolio project while keeping the scope realistic.

Each sprint should produce a visible, testable result.

---

## 2. Development Principles

1. Build small and ship often.
2. Keep MVP scope strict.
3. Prefer stable core features over many unfinished features.
4. Document decisions while building.
5. Use GitHub issues for tasks.
6. Keep every sprint demo-ready.
7. Add tests for important business logic.
8. Keep UI polished from the beginning.

---

## 3. Recommended Sprint Cadence

Each sprint should include:

- Planning
- Implementation
- Testing
- Documentation update
- Demo recording or screenshot update
- Retrospective note

### Weekly rhythm

| Day | Focus |
|---|---|
| Day 1 | Sprint planning, issues, architecture decisions |
| Day 2-4 | Main implementation |
| Day 5 | Tests, bug fixes, UI polish |
| Day 6 | Documentation, screenshots, cleanup |
| Day 7 | Review, demo, next sprint planning |

---

## 4. Sprint 0 — Repository and Foundation

### Goal

Create a professional open-source project foundation.

### Scope

- Create Flutter project.
- Setup GitHub repo.
- Setup base folder structure.
- Add linting rules.
- Add CI workflow.
- Add base documentation.
- Add dependency plan.
- Add issue templates.
- Add app metadata.

### Tasks

- [ ] Create Flutter project: `openlife_routine`.
- [ ] Add `README.md`.
- [ ] Add `LICENSE`.
- [ ] Add `roadmap.md`.
- [ ] Add `architecture.md`.
- [ ] Add `design-system.md`.
- [ ] Add `animation-guidelines.md`.
- [ ] Add `.github/ISSUE_TEMPLATE`.
- [ ] Add `.github/PULL_REQUEST_TEMPLATE.md`.
- [ ] Add GitHub Actions for analyze and test.
- [ ] Add strict lint rules.
- [ ] Add initial app icon placeholder.
- [ ] Add base theme files.

### Acceptance Criteria

- [ ] App runs on Android emulator.
- [ ] CI passes.
- [ ] Lint passes.
- [ ] README explains the project clearly.
- [ ] Repo looks professional from day one.

### Demo

- Show app shell running.
- Show GitHub repo structure.

---

## 5. Sprint 1 — Design System and App Shell

### Goal

Build the core visual foundation based on the Calm Daily Companion design concept.

### Scope

- Theme tokens.
- Typography.
- Colors.
- Spacing.
- Radius.
- Buttons.
- Cards.
- Bottom navigation.
- App scaffold.
- Basic routing.
- Templates remain inside the Routines flow for MVP.

### Tasks

- [ ] Implement color tokens.
- [ ] Implement typography tokens.
- [ ] Implement spacing and radius constants.
- [ ] Create `PrimaryButton`.
- [ ] Create `IconCircleButton`.
- [ ] Create `RoutineCard` UI-only component.
- [ ] Create `WeekDateSelector` UI-only component.
- [ ] Create `ProgressRing` UI-only component.
- [ ] Create `OpenLifeBottomNav`.
- [ ] Setup routing with `go_router`.
- [ ] Create empty screen shells:
- [ ] Onboarding
- [ ] Today
- [ ] Routines
- [ ] New Routine
- [ ] Routine Detail
- [ ] Insights
- [ ] Templates
  - [ ] Settings

### Acceptance Criteria

- [ ] The app visually follows the design concept.
- [ ] Navigation works between main tabs.
- [ ] UI components are reusable.
- [ ] Light and dark theme can be toggled internally.

### Demo

- Record a short video of navigation and screen shells.

---

## 6. Sprint 2 — Onboarding and First Run Experience

### Goal

Create a friendly first experience that explains privacy-first and offline-first behavior.

### Scope

- Onboarding pages.
- Rive placeholder integration.
- Permission education screen.
- First-run flag.
- Language foundation.

### Tasks

- [ ] Build 3 onboarding pages:
  - [ ] Build better days
  - [ ] Private by default
  - [ ] Smart daily routines
- [ ] Add Rive animation placeholder area.
- [ ] Add local first-run persistence.
- [ ] Add notification permission explanation.
- [ ] Add skip onboarding.
- [ ] Add complete onboarding action.
- [ ] Add English and Indonesian localization structure.
- [ ] Add supportive onboarding copy.

### Acceptance Criteria

- [ ] First-time user sees onboarding.
- [ ] Returning user goes to Today screen.
- [ ] Onboarding can be skipped.
- [ ] No forced login.
- [ ] UI feels calm and modern.

### Demo

- Show onboarding flow and transition to Today screen.

---

## 7. Sprint 3 — Local Database and Routine CRUD

### Goal

Implement core routine data management.

### Scope

- Local database.
- Routine entity.
- Routine model.
- Routine repository.
- Routine BLoC.
- Create/edit/delete routine.

### Tasks

- [ ] Choose local database implementation.
  - Recommended: Drift over SQLite for type-safe queries and migrations.
- [ ] Define routine table.
- [ ] Define routine schedule table.
- [ ] Define routine log table.
- [ ] Create domain entities.
- [ ] Create repository interface.
- [ ] Create local data source.
- [ ] Create use cases:
  - [ ] CreateRoutine
  - [ ] UpdateRoutine
  - [ ] DeleteRoutine
  - [ ] GetRoutine
  - [ ] WatchRoutines
- [ ] Create Routine BLoC.
- [ ] Connect New Routine form to real data.
- [ ] Connect routine list to local database.

### Acceptance Criteria

- [ ] User can create a routine.
- [ ] User can edit a routine.
- [ ] User can delete a routine.
- [ ] Data survives app restart.
- [ ] Routine list updates reactively.

### Demo

- Create, edit, delete routine on emulator.

---

## 8. Sprint 4 — Today Screen and Daily Checklist

### Goal

Make the Today screen work with real routines and daily completion logs.

### Scope

- Daily filtering.
- Today checklist.
- Mark done.
- Skip routine.
- Daily progress.
- 7-day date selector behavior.

### Tasks

- [ ] Implement current day routine query.
- [ ] Implement selected date state.
- [ ] Implement daily routine log creation.
- [ ] Add mark as done use case.
- [ ] Add skip routine use case.
- [ ] Add undo action.
- [ ] Add daily progress calculation.
- [ ] Connect progress ring to real data.
- [ ] Add empty state if no routines exist.
- [ ] Add Today BLoC.
- [ ] Add tests for progress calculation.

### Acceptance Criteria

- [ ] Today screen shows only routines scheduled for selected day.
- [ ] Mark as done works.
- [ ] Skip works.
- [ ] Progress percentage updates instantly.
- [ ] Empty state is shown when no routines exist.

### Demo

- Complete routines and show progress animation.

---

## 9. Sprint 5 — Local Notification and Reminder Engine

### Goal

Make reminders work reliably using local notifications.

### Scope

- Notification permission.
- Reminder scheduling.
- Reminder cancellation.
- Snooze.
- Reschedule after app restart.
- Timezone handling.

### Tasks

- [ ] Add `flutter_local_notifications`.
- [ ] Add timezone initialization.
- [ ] Create NotificationService.
- [ ] Create ReminderScheduler.
- [ ] Schedule routine notification after routine creation.
- [ ] Update notification after routine update.
- [ ] Cancel notification after routine deletion.
- [ ] Add snooze support.
- [ ] Add notification payload.
- [ ] Handle notification tap.
- [ ] Add notification permission UI.
- [ ] Add duplicate prevention.
- [ ] Add tests for reminder scheduling logic.

### Acceptance Criteria

- [ ] Notification triggers at selected time.
- [ ] Updated routines update notification schedule.
- [ ] Deleted routines cancel notifications.
- [ ] Snooze works.
- [ ] Notification tap opens relevant routine.
- [ ] No notification spam.

### Demo

- Create reminder one minute ahead and show notification.

---

## 10. Sprint 6 — Rive Animation and Micro-Interactions

### Goal

Add meaningful Rive animations and UI motion.

### Scope

- Onboarding animation.
- Empty state animation.
- Check done animation.
- Reminder active animation.
- Daily complete celebration.
- Native Flutter micro-interactions.

### Tasks

- [ ] Define Rive asset list.
- [ ] Add `rive` package.
- [ ] Create `RiveAnimationView` wrapper.
- [ ] Add fallback image support.
- [ ] Add onboarding Rive.
- [ ] Add empty state Rive.
- [ ] Add check done Rive.
- [ ] Add daily complete Rive.
- [ ] Add progress ring animation.
- [ ] Add haptic feedback for done action.
- [ ] Add animated card state changes.
- [ ] Validate performance.

### Acceptance Criteria

- [ ] Rive assets load safely.
- [ ] App does not crash if animation fails.
- [ ] Animations feel calm and useful.
- [ ] No visible performance drop on mid-range device.

### Demo

- Show onboarding, empty state, done action, and complete celebration.

---

## 11. Sprint 7 — Templates and Insights

### Goal

Help users start faster and understand their weekly consistency.

### Scope

- Template list.
- Template detail.
- Create routine from template.
- 7-day insights.
- Completion rate.
- Most missed routine.
- Streak.

### Tasks

- [ ] Define template model.
- [ ] Create seed templates:
  - [ ] Basic Healthy Routine
  - [ ] Hydration Routine
  - [ ] Vitamin Routine
  - [ ] Sleep Routine
  - [ ] Programmer Break Routine
- [ ] Build Templates screen.
- [ ] Build Template Detail screen.
- [ ] Create routines from template.
- [ ] Build Insights BLoC.
- [ ] Add weekly completion chart.
- [ ] Add most completed/missed routine summary.
- [ ] Add streak calculation.
- [ ] Add tests for insights calculations.

### Acceptance Criteria

- [ ] User can create routines from templates.
- [ ] Insights screen shows real data.
- [ ] Weekly report is simple and understandable.
- [ ] No medical claims in templates.

### Demo

- Create template routines and show insights after marking logs.

---

## 12. Sprint 8 — Backup, Settings, and Privacy Polish

### Goal

Complete core utility and privacy controls.

### Scope

- Settings screen.
- Language setting.
- Theme setting.
- Export JSON.
- Import JSON.
- Data reset.
- Privacy information.
- About open source.

### Tasks

- [ ] Build Settings screen.
- [ ] Add theme toggle.
- [ ] Add language toggle.
- [ ] Add notification settings.
- [ ] Add export JSON.
- [ ] Add import JSON.
- [ ] Add backup validation.
- [ ] Add reset data confirmation.
- [ ] Add privacy-first explanation.
- [ ] Add GitHub link section.
- [ ] Add app version display.

### Acceptance Criteria

- [ ] User can export local data.
- [ ] User can import valid backup.
- [ ] User can reset data with confirmation.
- [ ] Settings are persisted.
- [ ] Privacy message is clear.

### Demo

- Export and import data successfully.

---

## 13. Sprint 9 — Testing, Accessibility, and Release Preparation

### Goal

Prepare the first public MVP release.

### Scope

- Testing.
- Accessibility.
- Performance.
- Screenshots.
- README polish.
- Release APK.
- Portfolio case study.

### Tasks

- [ ] Add unit tests for routine logic.
- [ ] Add unit tests for progress logic.
- [ ] Add unit tests for schedule logic.
- [ ] Add widget tests for key screens.
- [ ] Add accessibility labels.
- [ ] Check touch target sizes.
- [ ] Check dark mode readability.
- [ ] Check small screen layout.
- [ ] Optimize asset sizes.
- [ ] Generate screenshots.
- [ ] Record demo video.
- [ ] Build release APK.
- [ ] Create GitHub Release.
- [ ] Write portfolio case study.

### Acceptance Criteria

- [ ] CI passes.
- [ ] Release APK works.
- [ ] README is recruiter-friendly.
- [ ] Demo video exists.
- [ ] App has no known critical bugs.

### Demo

- Public MVP walkthrough.

---

## 14. Backlog After MVP

### Product Backlog

- [ ] Dependent reminders.
- [ ] Reminder escalation.
- [ ] Custom snooze duration.
- [ ] Home screen widget.
- [ ] Monthly insights.
- [ ] Encrypted backup.
- [ ] More templates.
- [ ] Family/caregiver mode.
- [ ] Optional cloud sync.
- [ ] Web dashboard.

### Open-Source Backlog

- [ ] Good first issues.
- [ ] Translation contribution guide.
- [ ] Design contribution guide.
- [ ] Architecture decision records.
- [ ] F-Droid build checklist.
- [ ] Dependency license report.

---

## 15. Definition of Done

A task is done when:

- [ ] Code is implemented.
- [ ] UI matches design direction.
- [ ] State handling is predictable.
- [ ] Error states are handled.
- [ ] Loading/empty states are handled.
- [ ] Tests are added where necessary.
- [ ] Lint passes.
- [ ] No obvious performance issue.
- [ ] Documentation is updated if behavior changes.

---

## 16. MVP Release Checklist

- [ ] App name and icon ready.
- [ ] Main screens complete.
- [ ] Routine CRUD complete.
- [ ] Today checklist complete.
- [ ] Local notification complete.
- [ ] Rive animations integrated.
- [ ] Templates complete.
- [ ] Insights complete.
- [ ] Backup/export complete.
- [ ] Settings complete.
- [ ] README complete.
- [ ] Architecture docs complete.
- [ ] Design docs complete.
- [ ] Tests pass.
- [ ] CI passes.
- [ ] APK release created.
- [ ] Demo video created.
- [ ] Portfolio case study written.
