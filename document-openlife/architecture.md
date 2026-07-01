# OpenLife Routine — Architecture

> **Product:** OpenLife Routine  
> **Platform:** Flutter mobile app  
> **Architecture Style:** Clean Architecture + Feature-first modules  
> **State Management:** Full BLoC
> **Data Strategy:** Offline-first local database  
> **Animation:** Rive  
> **Architecture Version:** v1.0

---

## 1. Architecture Goal

The architecture of OpenLife Routine must prove that the app is not only visually polished, but also engineered like a maintainable production Flutter application.

The architecture should support:

- Offline-first usage.
- No forced login.
- Local notification scheduling.
- Routine and checklist management.
- Clean business logic separation.
- Testable use cases.
- Scalable future modules such as cloud sync and family mode.
- Open-source contributor friendliness.

---

## 2. Core Architecture Principles

### 2.1 Offline-first by default

All core features must work without internet:

- Routine creation
- Daily checklist
- Mark done/skip
- Reminder scheduling
- Local history
- Templates
- Settings
- Backup/export

Cloud sync must remain optional in future versions.

### 2.2 Privacy-first by default

The app should not require account registration for the MVP.

Data should stay on the device unless the user intentionally exports or syncs it.

### 2.3 Feature-first structure

The project should be organized by features first, then layers inside each feature.

This keeps the repository easier to navigate for open-source contributors.

### 2.4 Business logic must be testable

Core logic such as progress calculation, date filtering, scheduling rules, and streak calculation should be testable without UI.

### 2.5 UI should be dumb and predictable

Widgets should display state and send events. Business decisions should live in BLoC/use cases/domain services.

---

## 3. Recommended Tech Stack

| Area | Recommendation | Notes |
|---|---|---|
| Framework | Flutter | Android first, iOS later |
| State management | flutter_bloc | Predictable and portfolio-friendly |
| Routing | go_router | Declarative navigation |
| Local database | Drift SQLite | Type-safe SQLite and migrations |
| Local notifications | flutter_local_notifications | Local reminder engine |
| Timezone | timezone | Correct scheduling behavior |
| Dependency injection | get_it + injectable or simple manual DI | Keep MVP simple |
| Models | freezed or plain immutable classes | Use if complexity grows |
| Equality | equatable | BLoC state comparison |
| Localization | Flutter gen-l10n | English + Indonesian |
| Animation | rive | Onboarding, empty state, completion |
| Charts | fl_chart or custom simple widgets | Keep insights lightweight |
| Testing | flutter_test, bloc_test, mocktail | Unit and widget tests |
| CI | GitHub Actions | analyze, test, build |

### Database note

Drift is recommended because it still uses SQLite while giving type-safe queries and migrations. If the project needs to stay extremely simple, `sqflite` is acceptable, but Drift gives better portfolio value.

---

## 4. High-Level Architecture

```text
Presentation Layer
  ↓ user events / UI state
Application Layer
  ↓ use cases / orchestration
Domain Layer
  ↓ entities / repository contracts / business rules
Data Layer
  ↓ local data sources / database / notification adapters
Platform Layer
  ↓ Android/iOS notifications, storage, permissions
```

### Layer responsibilities

| Layer | Responsibility |
|---|---|
| Presentation | Screens, widgets, BLoC, UI state |
| Application | Use cases, workflow orchestration |
| Domain | Entities, value objects, repository contracts, pure business rules |
| Data | Database implementation, local data source, mappers |
| Platform | Notifications, permissions, file picker, export/import |

---

## 5. Folder Structure

Recommended structure:

```text
lib/
  app/
    app.dart
    app_router.dart
    app_theme.dart
    app_localizations.dart
    bootstrap.dart

  core/
    constants/
    errors/
    extensions/
    localization/
    logging/
    result/
    services/
      clock_service.dart
      permission_service.dart
    theme/
      app_colors.dart
      app_spacing.dart
      app_radius.dart
      app_text_styles.dart
    utils/

  shared/
    widgets/
      buttons/
      cards/
      empty_states/
      feedback/
      progress/
      rive/
    animations/
    icons/

  features/
    onboarding/
      presentation/
      application/

    routines/
      domain/
        entities/
        repositories/
        usecases/
        services/
      data/
        datasources/
        models/
        mappers/
        repositories/
      presentation/
        bloc/
        pages/
        widgets/

    today/
      domain/
      data/
      presentation/

    reminders/
      domain/
      data/
      presentation/
      platform/

    insights/
      domain/
      data/
      presentation/

    templates/
      domain/
      data/
      presentation/

    settings/
      domain/
      data/
      presentation/

  database/
    app_database.dart
    tables/
    migrations/

  notifications/
    notification_service.dart
    notification_channels.dart
    notification_payload.dart

  main.dart
```

---

## 6. Feature Modules

## 6.1 Onboarding Feature

### Responsibility

- Explain product value.
- Explain offline-first and privacy-first behavior.
- Request or educate about notification permission.
- Store first-run completion flag.

### Key screens

- Onboarding page 1: Build better days.
- Onboarding page 2: Private by default.
- Onboarding page 3: Reminders that fit your routine.

---

## 6.2 Routines Feature

### Responsibility

- Create routine.
- Edit routine.
- Delete routine.
- Enable/disable routine.
- Manage repeat days.
- Manage category.
- Manage reminder time.

### Main entities

- Routine
- RoutineSchedule
- RoutineCategory
- ReminderRule

### Main use cases

- CreateRoutine
- UpdateRoutine
- DeleteRoutine
- GetRoutineById
- WatchAllRoutines
- ToggleRoutineEnabled

---

## 6.3 Today Feature

### Responsibility

- Display routines for selected date.
- Mark routine as done.
- Skip routine.
- Calculate daily progress.
- Display today summary.

### Main entities

- DailyRoutineItem
- RoutineLog
- DailyProgress

### Main use cases

- GetRoutinesForDate
- MarkRoutineDone
- SkipRoutine
- UndoRoutineLog
- CalculateDailyProgress

---

## 6.4 Reminders Feature

### Responsibility

- Schedule local notifications.
- Cancel reminders.
- Update reminders.
- Snooze reminders.
- Handle notification tap.
- Prevent duplicate notifications.

### Main services

- ReminderScheduler
- NotificationService
- NotificationPermissionService
- ReminderPayloadParser

---

## 6.5 Insights Feature

### Responsibility

- Weekly summary.
- Completion rate.
- Most completed routine.
- Most missed routine.
- Streak.

### Main use cases

- GetWeeklyInsights
- CalculateCompletionRate
- CalculateRoutineStreak
- GetMostMissedRoutine

---

## 6.6 Templates Feature

### Responsibility

- Display routine templates.
- Preview template content.
- Create routines from template.

### Main templates

- Basic Healthy Routine
- Hydration Routine
- Vitamin Routine
- Sleep Routine
- Programmer Break Routine

---

## 6.7 Settings Feature

### Responsibility

- Theme mode.
- Language.
- Notification settings.
- Export/import.
- Privacy information.
- App version.
- Open-source links.

---

## 7. Domain Model

## 7.1 Routine

```text
Routine
- id: String
- title: String
- description: String?
- category: RoutineCategory
- iconKey: String
- colorKey: String
- isEnabled: bool
- createdAt: DateTime
- updatedAt: DateTime
```

## 7.2 RoutineSchedule

```text
RoutineSchedule
- id: String
- routineId: String
- repeatDays: List<Weekday>
- timeOfDay: LocalTime
- timezone: String
- startDate: Date?
- endDate: Date?
```

## 7.3 ReminderRule

```text
ReminderRule
- id: String
- routineId: String
- enabled: bool
- reminderTime: LocalTime
- snoozeMinutes: int
- repeatIfMissed: bool
- maxRepeatCount: int
- repeatIntervalMinutes: int
```

## 7.4 RoutineLog

```text
RoutineLog
- id: String
- routineId: String
- date: Date
- status: RoutineLogStatus
- completedAt: DateTime?
- skippedAt: DateTime?
- skipReason: String?
- createdAt: DateTime
```

### RoutineLogStatus

```text
pending
completed
skipped
missed
snoozed
```

## 7.5 RoutineTemplate

```text
RoutineTemplate
- id: String
- title: String
- description: String
- category: RoutineCategory
- routines: List<TemplateRoutineItem>
- isPremium: bool
```

---

## 8. Local Database Design

### Recommended tables

```text
routines
routine_schedules
reminder_rules
routine_logs
routine_templates
settings
```

### `routines`

```text
id TEXT PRIMARY KEY
title TEXT NOT NULL
description TEXT NULL
category TEXT NOT NULL
icon_key TEXT NOT NULL
color_key TEXT NOT NULL
is_enabled INTEGER NOT NULL
created_at TEXT NOT NULL
updated_at TEXT NOT NULL
```

### `routine_schedules`

```text
id TEXT PRIMARY KEY
routine_id TEXT NOT NULL
repeat_days TEXT NOT NULL
reminder_time TEXT NOT NULL
timezone TEXT NOT NULL
start_date TEXT NULL
end_date TEXT NULL
```

### `reminder_rules`

```text
id TEXT PRIMARY KEY
routine_id TEXT NOT NULL
enabled INTEGER NOT NULL
snooze_minutes INTEGER NOT NULL
repeat_if_missed INTEGER NOT NULL
max_repeat_count INTEGER NOT NULL
repeat_interval_minutes INTEGER NOT NULL
```

### `routine_logs`

```text
id TEXT PRIMARY KEY
routine_id TEXT NOT NULL
date TEXT NOT NULL
status TEXT NOT NULL
completed_at TEXT NULL
skipped_at TEXT NULL
skip_reason TEXT NULL
created_at TEXT NOT NULL
```

### `settings`

```text
key TEXT PRIMARY KEY
value TEXT NOT NULL
updated_at TEXT NOT NULL
```

---

## 9. State Management

Use full BLoC for predictable state handling. Do not use Cubit in this project.

### Recommended BLoCs

| BLoC | Responsibility |
|---|---|
| OnboardingBloc | First-run flow |
| RoutineBloc | Create/edit/delete routines |
| TodayBloc | Today list, selected date, completion actions |
| ReminderBloc | Permission and scheduling status |
| InsightsBloc | Weekly report |
| TemplateBloc | Template list and template import |
| SettingsBloc | Theme, language, preferences |

### Example TodayBloc events

```text
TodayStarted
TodayDateSelected
TodayRoutineMarkedDone
TodayRoutineSkipped
TodayRoutineUndoRequested
```

### Example TodayBloc state

```text
TodayState
- selectedDate
- routines
- progress
- nextReminder
- isLoading
- errorMessage
```

---

## 10. Data Flow Examples

## 10.1 Create Routine Flow

```text
NewRoutinePage
  → RoutineBloc.add(CreateRoutineRequested)
  → CreateRoutineUseCase
  → RoutineRepository.createRoutine
  → RoutineLocalDataSource.insertRoutine
  → ReminderScheduler.scheduleRoutineReminder
  → RoutineBloc emits success
  → UI navigates back to Today
```

## 10.2 Mark Done Flow

```text
TodayPage
  → TodayBloc.add(TodayRoutineMarkedDone)
  → MarkRoutineDoneUseCase
  → RoutineLogRepository.upsertLog
  → ReminderScheduler.cancelPendingReminderForToday
  → TodayBloc refreshes daily progress
  → UI plays check done animation
```

## 10.3 Reminder Trigger Flow

```text
Local notification fires
  → User taps notification
  → App receives notification payload
  → Router opens Routine Detail or Today Screen
  → User marks done / snoozes / skips
  → Log and schedule are updated
```

---

## 11. Reminder Architecture

## 11.1 ReminderScheduler

The ReminderScheduler is responsible for translating routine schedules into platform notifications.

Responsibilities:

- Schedule notification.
- Reschedule notification.
- Cancel notification.
- Snooze notification.
- Rebuild notification schedule after app restart.
- Prevent duplicate schedules.

## 11.2 Notification ID strategy

Use deterministic notification IDs to avoid duplicates.

Example:

```text
notificationId = hash(routineId + date + reminderType)
```

## 11.3 Timezone handling

The app should store:

- Local time selected by user.
- Timezone name.
- Date calculation based on local timezone.

Use timezone-aware scheduling for notifications.

## 11.4 Platform limitations

Android and iOS have different limitations around exact alarms and background behavior. MVP should document known limitations and avoid overpromising notification reliability.

---

## 12. Rive Architecture

Use a shared wrapper for Rive animations.

```text
shared/widgets/rive/openlife_rive_view.dart
```

The wrapper should handle:

- Asset loading.
- Artboard name.
- State machine name.
- Input triggers.
- Fallback widget.
- Error handling.

Example usage:

```text
OpenLifeRiveView(
  asset: OpenLifeRiveAssets.checkDone,
  artboard: 'CheckDone',
  stateMachine: 'CheckDoneStateMachine',
  fallback: Icon(Icons.check_circle),
)
```

---

## 13. Error Handling

Use a simple `Result<T>` pattern or typed failures.

### Common failure types

- DatabaseFailure
- NotificationPermissionFailure
- NotificationScheduleFailure
- BackupImportFailure
- ValidationFailure
- UnknownFailure

### UI behavior

Errors should be supportive and clear.

Good message:

> We couldn’t save this routine. Please try again.

Avoid:

> Fatal database exception.

---

## 14. Validation Rules

### Routine title

- Required.
- Minimum 1 character.
- Maximum 60 characters.

### Reminder time

- Required if reminder is enabled.

### Repeat days

- At least one day must be selected.

### Snooze

- Minimum 5 minutes.
- Maximum 120 minutes.

---

## 15. Testing Strategy

### Unit tests

- Routine validation.
- Today filtering.
- Progress calculation.
- Streak calculation.
- Reminder ID generation.
- Schedule calculation.
- Backup serialization.

### BLoC tests

- Create routine success.
- Create routine validation error.
- Mark done updates progress.
- Skip routine updates log.
- Load insights success.

### Widget tests

- Today screen empty state.
- Routine card done state.
- New Routine form validation.
- Settings screen toggle.

### Manual tests

- Notification permission.
- Notification trigger.
- App restart persistence.
- Theme switching.
- Export/import.
- Small screen layout.

---

## 16. CI/CD

### GitHub Actions workflow

Run on push and pull request:

```text
flutter pub get
flutter analyze
flutter test
```

Optional release workflow:

```text
flutter build apk --release
```

### Required checks before merge

- Analyze passes.
- Tests pass.
- No generated files missing.
- Documentation updated if needed.

---

## 17. Security and Privacy

### MVP privacy rules

- No account required.
- No analytics by default.
- No third-party tracking.
- No ads.
- Data stored locally.
- Export/import controlled by user.

### Future sync privacy rules

- Sync must be optional.
- Privacy policy must be clear.
- Sensitive data should be encrypted before upload.
- User should be able to delete cloud data.

---

## 18. Future Architecture Expansion

The architecture should make these future features possible:

- Optional cloud sync.
- Family/caregiver mode.
- Encrypted backup.
- Widgets.
- B2B coach dashboard.
- Premium templates.
- Web dashboard.

To prepare for this, keep repository interfaces independent from local implementations.

Example:

```text
RoutineRepository
  → LocalRoutineRepository now
  → SyncRoutineRepository later
```

---

## 19. Architecture Decision Records

Create ADR files when making important decisions.

Recommended path:

```text
docs/adr/
  0001-use-flutter-bloc.md
  0002-use-drift-for-local-database.md
  0003-use-rive-for-animation.md
  0004-offline-first-core.md
```

---

## 20. Architecture Summary

OpenLife Routine should be built as a clean, offline-first Flutter application with:

- Feature-first module organization.
- Clean Architecture layers.
- BLoC for predictable state.
- Drift SQLite for local data.
- Local notifications for reminders.
- Rive for purposeful animation.
- Strong documentation for open-source credibility.

The goal is not only to build an app that works, but also to build a codebase that demonstrates professional mobile engineering quality.
