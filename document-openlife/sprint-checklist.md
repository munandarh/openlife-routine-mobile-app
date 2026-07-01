# OpenLife Routine — Sprint Execution Checklist

> **Purpose:** Single execution tracker for implementation progress.
> **Rule:** Every completed task must be checked immediately.
> **Architecture rule:** Use full BLoC only. Do not use Cubit.
> **MVP navigation rule:** Bottom navigation stays `Today / Routines / Insights / Settings`. `Templates` lives under `Routines`, not as a main tab.
> **Git rule:** No `git commit` or `git push` during execution.

---

## 0. Product Lock

- [x] Product direction read from `document-openlife`
- [x] UI reference screens read from `ui-ux-design-screen`
- [x] Design direction locked to warm cream + sage + large rounded cards
- [x] Full BLoC rule locked
- [x] MVP navigation locked to 4 tabs
- [x] Final package choices confirmed in codebase setup

---

## 1. Sprint 0 — Foundation

### Decision lock
- [x] Flutter app scaffold available
- [x] Folder structure follows feature-first clean architecture
- [x] `flutter_bloc` selected for state management
- [ ] Local DB approach locked
- [ ] Notification stack locked
- [x] Routing approach locked
- [x] Localization approach locked

### Repo setup
- [ ] Base app runs on Android emulator
- [x] Theme token files created
- [x] Base router created
- [ ] Base dependency injection approach created
- [x] Linting configured
- [x] Test command works
- [x] CI workflow prepared

### Review gate
- [ ] Sprint 0 demo ready
- [ ] Sprint 0 checklist fully reviewed

---

## 2. Sprint 1 — Design System App Shell

### Tokens
- [ ] Color tokens implemented from `serene_routine`
- [ ] Typography tokens implemented with Plus Jakarta Sans
- [ ] Spacing tokens implemented
- [ ] Radius tokens implemented
- [ ] Shadow tokens implemented
- [ ] Light theme implemented
- [ ] Dark theme baseline implemented

### Shared UI
- [ ] `PrimaryButton` built
- [ ] `IconCircleButton` built
- [ ] `RoutineCard` UI-only built
- [ ] `WeekDateSelector` UI-only built
- [ ] `ProgressRing` UI-only built
- [ ] `OpenLifeBottomNav` built with 4 tabs only
- [ ] Empty state component built

### Screen shells
- [ ] Onboarding shell built
- [ ] Today shell built
- [ ] Routines shell built
- [ ] New Routine shell built
- [ ] Routine Detail shell built
- [ ] Insights shell built
- [ ] Templates shell built under Routines flow
- [ ] Settings shell built

### Review gate
- [ ] Screens visually align with `ui-ux-design-screen`
- [ ] Navigation works
- [ ] No extra main tab for Templates

---

## 3. Sprint 2 — Onboarding First Run

- [ ] 3 onboarding pages built
- [ ] Skip onboarding works
- [ ] Complete onboarding works
- [ ] First-run persistence works
- [ ] Notification education screen built
- [ ] Language selection entry built
- [ ] Supportive copy aligned with design docs
- [ ] Rive placeholder or static illustration fallback added

### Review gate
- [ ] First launch goes to onboarding
- [ ] Returning launch goes to Today

---

## 4. Sprint 3 — Routine CRUD

### Domain and data
- [ ] Routine entity created
- [ ] Routine schedule entity created
- [ ] Routine log entity created
- [ ] Repository contracts created
- [ ] Local data source created
- [ ] Database tables created

### Application
- [ ] CreateRoutine use case built
- [ ] UpdateRoutine use case built
- [ ] DeleteRoutine use case built
- [ ] GetRoutine use case built
- [ ] WatchRoutines use case built

### Presentation
- [ ] RoutineBloc built
- [ ] New Routine form connected
- [ ] Routines list screen connected
- [ ] Edit routine flow connected
- [ ] Delete routine flow connected

### Review gate
- [ ] Create routine works
- [ ] Edit routine works
- [ ] Delete routine works
- [ ] Data survives restart

---

## 5. Sprint 4 — Today Checklist

- [ ] Selected date state implemented
- [ ] Query routines by selected date implemented
- [ ] Daily log creation implemented
- [ ] Mark done implemented
- [ ] Skip routine implemented
- [ ] Undo action implemented
- [ ] Progress calculation implemented
- [ ] TodayBloc built
- [ ] Today screen bound to real data
- [ ] Empty state bound correctly

### Review gate
- [ ] Only scheduled routines appear
- [ ] Progress updates instantly
- [ ] Due state and done state match UI direction

---

## 6. Sprint 5 — Reminder Engine

- [ ] Notification permission flow built
- [ ] Notification service built
- [ ] Reminder scheduler built
- [ ] Timezone initialization built
- [ ] Create schedule on routine creation
- [ ] Update schedule on routine update
- [ ] Cancel schedule on routine delete
- [ ] Snooze flow built
- [ ] Notification payload handling built
- [ ] Duplicate prevention built
- [ ] Rebuild schedules after restart built

### Review gate
- [ ] Notification fires on time
- [ ] No duplicate spam
- [ ] Tap opens relevant app flow

---

## 7. Sprint 6 — Motion and Polish

- [ ] Shared Rive wrapper built
- [ ] Static fallback support built
- [ ] Onboarding animation integrated
- [ ] Empty state animation integrated
- [ ] Done check animation integrated
- [ ] Daily complete animation integrated
- [ ] Progress ring animation integrated
- [ ] Haptic feedback added
- [ ] Motion respects calm design direction

### Review gate
- [ ] No animation crash
- [ ] No obvious jank
- [ ] Only meaningful motion remains

---

## 8. Sprint 7 — Templates and Insights

### Templates
- [ ] Template model created
- [ ] Seed templates created
- [ ] Templates list built
- [ ] Template detail built
- [ ] Apply template flow built

### Insights
- [ ] InsightsBloc built
- [ ] Weekly completion metric built
- [ ] Most completed routine metric built
- [ ] Most missed routine metric built
- [ ] Streak metric built
- [ ] Weekly chart built

### Review gate
- [ ] Templates entered through Routines flow
- [ ] No medical claims in template content
- [ ] Insights are supportive, not judgmental

---

## 9. Sprint 8 — Settings, Backup, Privacy

- [ ] Settings screen connected
- [ ] Theme setting connected
- [ ] Language setting connected
- [ ] Notification setting connected
- [ ] Export JSON built
- [ ] Import JSON built
- [ ] Backup validation built
- [ ] Reset data flow built
- [ ] Privacy screen built
- [ ] About open source screen built

### Review gate
- [ ] Settings persist
- [ ] Export and import work
- [ ] Privacy messaging stays clear

---

## 10. Sprint 9 — Test and Release Prep

- [ ] Unit tests for routine logic
- [ ] Unit tests for progress logic
- [ ] Unit tests for scheduling logic
- [ ] Widget tests for core screens
- [ ] Accessibility labels added
- [ ] Small-screen QA done
- [ ] Dark-mode QA done
- [ ] Asset optimization done
- [ ] Screenshots prepared
- [ ] Demo video prepared
- [ ] Release APK built locally

### Review gate
- [ ] CI passes
- [ ] No known critical bug
- [ ] MVP release checklist reviewed

---

## 11. Daily Working Rule

- [ ] Pick tasks only from active sprint
- [ ] Finish one vertical slice at a time
- [ ] Check task immediately after verification
- [ ] Update docs when behavior changes
- [ ] Do not commit or push
