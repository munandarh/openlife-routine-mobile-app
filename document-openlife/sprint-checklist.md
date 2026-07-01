# OpenLife Routine — Sprint Execution Checklist

**Purpose:** Single execution tracker for implementation progress.
**Rule:** Completed task checked immediately.
**Architecture rule:** Use full BLoC only. Do not use Cubit.
**MVP navigation rule:** Bottom navigation stays `Today / Routines / Insights / Settings`. `Templates` lives under `Routines`, not main tab.
**Git rule:** No `git commit` or `git push` during execution.

---

## 0. Product Lock

- [x] Product direction read from `document-openlife`
- [x] UI reference screens read from `ui-ux-design-screen`
- [x] Design direction locked warm cream + sage + large rounded cards
- [x] Full BLoC rule locked
- [x] MVP navigation locked 4 tabs
- [x] Final package choices confirmed in codebase setup

---

## 1. Sprint 0 — Foundation

### Decision lock

- [x] Flutter app scaffold available
- [x] Folder structure follows feature-first clean architecture
- [x] `flutter_bloc` selected state management
- [x] Local DB approach locked
- [x] Notification stack locked
- [x] Routing approach locked
- [x] Localization approach locked

### Repo setup

- [x] Base app runs on Android emulator
- [x] Theme token files created
- [x] Base router created
- [x] Base dependency injection approach created
- [x] Linting configured
- [x] Test command works
- [x] CI workflow prepared

### Review gate

- [x] Sprint 0 demo ready
- [x] Sprint 0 checklist fully reviewed

---

## 2. Sprint 1 — Design System App Shell

### Tokens

- [x] Color tokens implemented `serene_routine`
- [x] Typography tokens implemented Plus Jakarta Sans
- [x] Spacing tokens implemented
- [x] Radius tokens implemented
- [x] Shadow tokens implemented
- [x] Light theme implemented
- [x] Dark theme baseline implemented

### Shared UI

- [x] `PrimaryButton` built
- [x] `IconCircleButton` built
- [x] `RoutineCard` UI-only built
- [x] `WeekDateSelector` UI-only built
- [x] `ProgressRing` UI-only built
- [x] `OpenLifeBottomNav` built 4 tabs only
- [x] Empty state component built

### Screen shells

- [x] Onboarding shell built
- [x] Today shell built
- [x] Routines shell built
- [x] New Routine shell built
- [x] Routine Detail shell built
- [x] Insights shell built
- [x] Templates shell built under Routines flow
- [x] Settings shell built

### Review gate

- [x] Screens visually align `ui-ux-design-screen`
- [x] Navigation works
- [x] No extra main tab Templates

---

## 3. Sprint 2 — Onboarding First Run

- [x] 3 onboarding pages built
- [x] Skip onboarding works
- [x] Complete onboarding works
- [x] First-run persistence works
- [x] Notification education screen built
- [x] Language selection entry built
- [x] Supportive copy aligned design docs
- [x] Rive placeholder or static illustration fallback added

### Review gate

- [x] First launch goes to onboarding
- [x] Returning launch goes Today

---

## 4. Sprint 3 — Routine CRUD

### Domain and data

- [x] Routine entity created
- [x] Routine schedule entity created
- [x] Routine log entity created
- [x] Repository contracts created
- [x] Local data source created
- [x] Database tables created

### Application

- [x] CreateRoutine use case built
- [x] UpdateRoutine use case built
- [x] DeleteRoutine use case built
- [x] GetRoutine use case built
- [x] WatchRoutines use case built

### Presentation

- [x] RoutineBloc built
- [x] New Routine form connected
- [x] Routines list screen connected
- [x] Edit routine flow connected
- [x] Delete routine flow connected

### Review gate

- [x] Create routine works
- [x] Edit routine works
- [x] Delete routine works
- [x] Data survives restart

---

## 5. Sprint 4 — Today Checklist

- [x] Selected date state implemented
- [x] Query routines by selected date implemented
- [x] Daily log creation implemented
- [x] Mark done implemented
- [x] Skip routine implemented
- [x] Undo action implemented
- [x] Progress calculation implemented
- [x] TodayBloc built
- [x] Today screen bound to real data
- [x] Empty state bound correctly

### Review gate

- [x] Only scheduled routines appear
- [x] Progress updates instantly
- [x] Due state and done state match UI direction

---

## 6. Sprint 5 — Reminder Engine

- [x] Notification permission flow built
- [x] Notification service built
- [x] Reminder scheduler built
- [x] Timezone initialization built
- [x] Create schedule on routine creation
- [x] Update schedule on routine update
- [x] Cancel schedule on routine delete
- [x] Snooze flow built
- [x] Notification payload handling built
- [x] Duplicate prevention built
- [x] Rebuild schedules restart built

### Review gate

- [x] Notification fires on time
- [x] No duplicate spam
- [x] Tap opens relevant app flow

---

## 7. Sprint 6 — Motion and Polish

- [x] Shared Rive wrapper built
- [x] Static fallback support built
- [x] Onboarding animation integrated
- [x] Empty state animation integrated
- [x] Done check animation integrated
- [x] Daily complete animation integrated
- [x] Progress ring animation integrated
- [x] Haptic feedback added
- [x] Motion respects calm design direction

### Review gate

- [x] No animation crash
- [x] No obvious jank
- [x] Only meaningful motion remains

---

## 8. Sprint 7 — Templates Insights

### Templates

- [x] Template model created
- [x] Seed templates created
- [x] Templates list built
- [x] Template detail built
- [x] Apply template flow built

### Insights

- [x] InsightsBloc built
- [x] Weekly completion metric built
- [x] Most completed routine metric built
- [x] Most missed routine metric built
- [x] Streak metric built
- [x] Weekly chart built

### Review gate

- [x] Templates entered through Routines flow
- [x] No medical claims in template content
- [x] Insights are supportive, not judgmental

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
- [ ] Export import work
- [ ] Privacy messaging stays clear

---

## 10. Sprint 9 — Test Release Prep

- [ ] Unit tests routine logic
- [ ] Unit tests progress logic
- [ ] Widget tests critical flows
- [ ] Manual QA pass complete
- [ ] Release build sanity check complete

### Review gate

- [ ] Release candidate stable
- [ ] No known blocker left
