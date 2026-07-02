# PRD — OpenLife Routine

**Product Name:** OpenLife Routine  
**Type:** Open-source mobile app  
**Platform:** Android first, iOS later  
**Tech Direction:** Flutter, BLoC, local-first database, local notifications, Rive animations  
**Document Version:** v1.0  
**Prepared For:** Open-source portfolio + long-term monetizable product  

---

## 1. Product Summary

**OpenLife Routine** adalah aplikasi mobile open-source, privacy-first, dan offline-first untuk membantu user menjalani rutinitas harian dengan lebih konsisten.

Fokus utama aplikasi ini adalah membantu user mengatur dan melacak rutinitas seperti:

- Makan
- Minum air
- Vitamin
- Obat
- Tidur
- Olahraga ringan
- Stretching
- Istirahat kerja
- Checklist pola hidup harian
- Rutinitas custom

OpenLife Routine bukan aplikasi diagnosis kesehatan, bukan pengganti dokter, dan bukan aplikasi medis klinis. Aplikasi ini adalah **daily routine and lifestyle reminder app** yang membantu user membangun hari yang lebih teratur.

### One-liner

> OpenLife Routine is an open-source, privacy-first daily routine reminder app built with Flutter to help people build better days, one routine at a time.

### Indonesian one-liner

> OpenLife Routine adalah aplikasi open-source untuk membantu orang menjalani rutinitas makan, minum, vitamin, obat, tidur, dan checklist harian secara privat dan konsisten.

---

## 2. Vision

Menjadi aplikasi open-source privacy-first terbaik untuk mengatur rutinitas harian, lifestyle reminder, dan family care routine dengan desain modern, sederhana, dan menyenangkan dipakai setiap hari.

### Long-term vision

OpenLife Routine dapat berkembang menjadi:

- Personal daily routine OS
- Offline-first habit and routine tracker
- Medication and supplement reminder
- Family/caregiver routine assistant
- Open-source alternative to commercial reminder/habit apps
- Portfolio flagship untuk membuktikan kemampuan Flutter production-ready

---

## 3. Main Goals

### 3.1 User goals

User dapat:

1. Membuat rutinitas harian dengan cepat.
2. Mendapat reminder sesuai jadwal.
3. Menandai rutinitas sebagai done, snooze, atau skip.
4. Melihat progress harian.
5. Melihat riwayat sederhana.
6. Menggunakan aplikasi tanpa akun.
7. Menyimpan data secara lokal dan privat.
8. Memakai template rutinitas agar tidak mulai dari nol.

### 3.2 Portfolio goals

Project ini harus membuktikan skill engineering yang kuat:

- Flutter production-ready app
- Clean Architecture
- BLoC state management
- Local-first database
- Local notification scheduler
- Rive animation integration
- Responsive UI
- Accessibility-aware UI
- Unit test dan widget test
- GitHub Actions CI
- Dokumentasi open-source profesional
- README, roadmap, contribution guide, architecture docs

### 3.3 Business goals

Untuk fase awal, tujuan bisnis utama bukan langsung monetisasi produk, tetapi:

1. Membuat flagship open-source portfolio.
2. Meningkatkan peluang remote job/freelance luar negeri.
3. Menjadi bukti kemampuan membangun aplikasi nyata dari nol.
4. Menyiapkan fondasi monetisasi jangka panjang.

Monetisasi produk bisa dilakukan setelah aplikasi memiliki user dan trust.

---

## 4. Problem Statement

Banyak orang ingin menjalani rutinitas hidup yang lebih sehat dan teratur, tetapi sering gagal karena:

- Lupa makan tepat waktu
- Lupa minum air
- Lupa minum vitamin atau obat
- Rutinitas tercecer di Notes, alarm, WhatsApp, atau kalender
- Reminder bawaan terlalu sederhana
- Habit tracker terlalu kompleks
- Banyak aplikasi meminta akun/cloud sejak awal
- User tidak percaya aplikasi yang menyimpan data kesehatan pribadi
- Reminder tidak punya logika lanjutan seperti “kalau sudah makan, ingatkan vitamin setelah 15 menit”

OpenLife Routine menyelesaikan masalah ini dengan aplikasi yang sederhana, offline-first, privacy-first, dan fokus pada rutinitas harian.

---

## 5. Target Users

### 5.1 Primary users

1. **Busy workers / remote workers**  
   Orang yang sibuk dan sering lupa makan, minum, istirahat, atau stretching.

2. **People building healthier routines**  
   Orang yang ingin hidup lebih teratur tanpa aplikasi yang terlalu kompleks.

3. **Supplement or medication users**  
   Orang yang perlu pengingat vitamin, suplemen, atau obat ringan.

4. **Programmers and desk workers**  
   Orang yang duduk lama dan butuh pengingat minum, stretching, istirahat mata, dan postur.

5. **Caregivers**  
   Orang yang membantu mengingatkan rutinitas keluarga seperti anak, pasangan, atau orang tua.

### 5.2 Secondary users

1. Flutter developers yang ingin belajar dari project open-source.
2. Recruiter luar negeri yang ingin melihat kualitas code.
3. Client freelance yang mencari Flutter developer.
4. Komunitas open-source yang ingin contribute template, translation, atau fitur.

---

## 6. Product Principles

### 6.1 Privacy-first

- Tidak wajib login.
- Data disimpan lokal secara default.
- Tidak menjual data user.
- Tidak menggunakan tracking agresif.
- User bisa export/import data.

### 6.2 Offline-first

- Semua fitur inti tetap berjalan tanpa internet.
- Reminder berjalan secara lokal.
- Database utama ada di device.
- Cloud sync hanya menjadi fitur opsional jangka panjang.

### 6.3 Simple but useful

- User harus bisa membuat reminder pertama dalam kurang dari 1 menit.
- Tampilan harus bersih dan mudah dipahami.
- Tidak terlalu banyak langkah.
- Fitur kompleks disimpan untuk versi berikutnya.

### 6.4 Calm, not stressful

- Wording tidak menyalahkan user.
- Tidak ada pesan seperti “You failed”.
- Gunakan bahasa yang supportive.
- Animasi harus halus, bukan ramai.

### 6.5 Open-source friendly

- Dokumentasi jelas.
- Struktur project rapi.
- Issue template tersedia.
- Contribution guide tersedia.
- Roadmap transparan.

---

## 7. MVP Scope

MVP harus fokus pada fitur inti yang menunjukkan nilai produk dan kualitas engineering.

### 7.1 MVP Feature List

| Priority | Feature | Description |
|---|---|---|
| P0 | Onboarding | Perkenalan singkat app, privacy-first, local-first |
| P0 | Create Routine | User bisa membuat rutinitas baru |
| P0 | Routine Category | Meal, water, vitamin, medicine, sleep, exercise, break, custom |
| P0 | Schedule Reminder | Set jam reminder lokal |
| P0 | Local Notification | Reminder muncul sesuai jadwal |
| P0 | Today Screen | Melihat rutinitas hari ini |
| P0 | Mark as Done | Menandai rutinitas selesai |
| P0 | Skip Routine | Menandai rutinitas dilewati |
| P0 | Snooze Reminder | Tunda reminder |
| P0 | Daily Progress | Progress hari ini dalam persentase |
| P0 | Local Database | Simpan routine, schedule, logs secara lokal |
| P0 | Settings | Theme, language, notification permission |
| P0 | Basic Rive Animations | Onboarding, empty state, completion animation |
| P1 | Routine Templates | Template basic untuk user baru |
| P1 | 7-Day History | Riwayat sederhana 7 hari terakhir |
| P1 | Import/Export JSON | Backup manual |
| P1 | Dark Mode | Theme terang dan gelap |
| P1 | Indonesian + English | Multi-language awal |

### 7.2 Out of Scope for MVP

Fitur berikut tidak masuk MVP:

- Login/register
- Cloud sync
- AI coach
- Family mode
- Web dashboard
- Subscription
- B2B clinic dashboard
- Medical diagnosis
- Integration smartwatch
- Push notification server
- Social features
- Community feed

---

## 8. Core Features Detail

## 8.1 Onboarding

### Objective

Mengenalkan value utama aplikasi tanpa membuat user merasa ribet.

### Screens

1. Welcome screen
2. Privacy-first explanation
3. Routine benefit screen
4. Notification permission request
5. Choose starter template or start empty

### Copy direction

- “Build better days, one routine at a time.”
- “Your data stays on your device.”
- “Start simple. Add routines anytime.”

### Rive animation usage

- Welcome animation: friendly character/checklist animation
- Privacy animation: shield/phone/local data visual
- Reminder animation: bell/calendar soft motion

---

## 8.2 Today Screen

### Objective

Menjadi layar utama yang menunjukkan apa yang harus dilakukan hari ini.

### Components

- Greeting
- Daily progress ring
- Next routine card
- List of today routines
- Quick add button
- Empty state if no routine

### Example layout

```text
Good morning
Today's routine is 60% complete

[Animated Progress Ring]
6 of 10 completed

Next
08:30 — Vitamin D3

Today
[ ] Breakfast        07:00
[x] Water            08:00
[ ] Vitamin D3       08:30
[ ] Stretching       10:00
```

### Actions

- Mark as done
- Snooze
- Skip
- Edit routine
- Add routine

### Rive animation usage

- Progress ring animation when completion changes
- Checkmark animation when a routine is completed
- Empty state illustration when there are no routines

---

## 8.3 Routine Creation

### Objective

User bisa membuat rutinitas dalam flow yang cepat dan mudah.

### Fields

| Field | Type | Required | Notes |
|---|---|---|---|
| Name | Text | Yes | Example: Breakfast |
| Category | Enum | Yes | Meal, water, vitamin, medicine, sleep, exercise, break, custom |
| Icon | Enum/SVG | No | Default by category |
| Time | Time picker | Yes | Local reminder time |
| Repeat | Repeat rule | Yes | Daily by default |
| Snooze duration | Number | No | Default 10 minutes |
| Reminder escalation | Toggle | No | For later version |
| Notes | Text | No | Optional |
| Active | Boolean | Yes | Default true |

### Category defaults

| Category | Default Icon | Example |
|---|---|---|
| Meal | Plate | Breakfast, lunch, dinner |
| Water | Bottle | Drink water |
| Vitamin | Capsule | Vitamin D3, B complex |
| Medicine | Pill | Daily medicine |
| Sleep | Moon | Sleep routine |
| Exercise | Shoes | Walk, workout |
| Break | Eye/desk | Stretching, eye rest |
| Custom | Sparkle/check | Any habit |

---

## 8.4 Reminder Engine

### MVP behavior

In MVP, reminder engine supports:

- Daily reminder by time
- Local notification
- Mark done from app
- Snooze from app
- Skip from app
- Missed state if user does not complete until end of day

### Future behavior

In later versions, reminder engine supports:

- Repeat if no response
- Dependent reminders
- Quiet hours
- Smart escalation
- Routine sequence
- Dynamic reminder based on completion

### Example future dependent reminder

```text
IF Breakfast is marked done
THEN remind Vitamin D3 after 15 minutes
```

### Example future escalation

```text
07:00 — Breakfast reminder
08:00 — Reminder again if not done
09:00 — Final reminder if still not done
```

---

## 8.5 Daily Checklist

### Objective

Mengubah rutinitas menjadi checklist harian yang mudah dipahami.

### Status

Routine instance per day can have status:

- Pending
- Done
- Skipped
- Missed
- Snoozed

### Daily reset

Setiap hari, app membuat instance baru dari routine aktif berdasarkan jadwal.

### End-of-day behavior

Routine yang belum selesai sampai hari berakhir menjadi `missed`.

---

## 8.6 Progress and History

### MVP progress

- Completion percentage today
- Completed count
- Pending count
- Skipped count
- Missed count

### P1 history

- 7-day completion summary
- Basic weekly chart
- Most completed routine
- Most missed routine

### Future analytics

- Monthly report
- Routine consistency score
- Streak
- Export PDF/CSV
- Insight message

---

## 8.7 Templates

### Objective

Membantu user mulai tanpa harus membuat semua dari nol.

### MVP template examples

#### Basic Healthy Day

- Wake up
- Drink water
- Breakfast
- Lunch
- Afternoon water
- Dinner
- Sleep preparation

#### Programmer Break Routine

- Drink water
- Eye rest
- Stretching
- Walk 5 minutes
- Posture check

#### Vitamin Routine

- Breakfast
- Probiotic after breakfast
- Vitamin D after breakfast
- B complex after lunch
- Magnesium at night

#### Sleep Routine

- Reduce screen time
- Prepare bed
- Sleep reminder

### Important wording

Templates must not claim to cure disease. Use wording like:

- “Support your routine”
- “Help you remember”
- “Lifestyle reminder”

Avoid wording like:

- “Cure GERD”
- “Fix insomnia”
- “Medical treatment plan”

---

## 9. Information Architecture

### Main navigation

MVP uses bottom navigation with 4 tabs:

1. Today
2. Routines
3. Insights
4. Settings

### Navigation tree

```text
App
├── Onboarding
├── Main
│   ├── Today
│   │   ├── Routine Detail
│   │   └── Quick Add Routine
│   ├── Routines
│   │   ├── Add Routine
│   │   ├── Edit Routine
│   │   └── Template Picker
│   ├── Insights
│   │   └── 7-Day History
│   └── Settings
│       ├── Notification Settings
│       ├── Theme Settings
│       ├── Language Settings
│       ├── Backup/Export
│       ├── Privacy
│       └── About Open Source
```

---

## 10. UX and Design Requirements

## 10.1 Design Style

Design harus terasa:

- Simple
- Modern
- Calm
- Friendly
- Clean
- Soft
- Trustworthy
- Lightweight
- Not medical-heavy
- Not childish

### Visual direction

> Modern wellness productivity app with soft vector illustrations and purposeful micro-animations.

## 10.2 Color Direction

Recommended palette direction:

| Token | Direction |
|---|---|
| Primary | Soft teal / green |
| Secondary | Calm blue |
| Accent | Warm yellow / orange |
| Background light | Off-white |
| Background dark | Dark navy / charcoal |
| Success | Soft green |
| Warning | Warm amber |
| Error | Soft red |
| Text | High contrast but not harsh |

Exact colors should be defined in `design-system.md`.

## 10.3 Typography

Requirements:

- Clean sans-serif font
- Clear hierarchy
- Large readable text for routine titles
- Friendly but professional tone
- Support English and Indonesian

Recommended fonts:

- Inter
- Nunito Sans
- Plus Jakarta Sans

## 10.4 Component Style

Components should use:

- Rounded cards
- Soft shadow or subtle border
- Large touch targets
- Simple icons
- Clear status chips
- Smooth transition
- Minimal visual noise

## 10.5 Animation Principles

Animations must be:

- Purposeful
- Short
- Smooth
- Lightweight
- Non-intrusive
- Accessible

Avoid:

- Too much movement
- Long animation delays
- Heavy animation on every screen
- Animation that blocks user action

---

## 11. Rive Animation Plan

Rive will be used as the main animation tool for polished vector animation.

### 11.1 Why Rive

Rive is selected because:

- Good for interactive vector animation
- Supports state machines
- Works well with Flutter
- Suitable for onboarding, empty states, progress, and celebration
- Helps app feel premium without relying on heavy video assets

### 11.2 Rive usage rules

Use Rive for:

- Onboarding illustration
- Empty state illustration
- Completion celebration
- Reminder visual
- Progress hero animation
- Small mascot/character states if needed

Do not use Rive for:

- Every button
- Every list item
- Large background animation on every screen
- Heavy looping animation that drains battery

### 11.3 Required Rive assets for MVP

| Asset Name | Screen | Purpose | States |
|---|---|---|---|
| `onboarding_welcome.riv` | Onboarding | Introduce app | idle, wave |
| `onboarding_privacy.riv` | Onboarding | Privacy/local-first visual | idle, shieldPulse |
| `empty_routine.riv` | Today/Routines | Empty state | idle |
| `routine_done.riv` | Today | Completion checkmark | playOnce |
| `daily_complete.riv` | Today | All routines complete | celebrate |
| `notification_bell.riv` | Reminder card | Reminder attention | idle, ring |

### 11.4 Future Rive assets

| Asset Name | Purpose |
|---|---|
| `sleep_routine.riv` | Sleep routine illustration |
| `water_goal.riv` | Hydration visual |
| `vitamin_capsule.riv` | Vitamin reminder visual |
| `streak_badge.riv` | Streak celebration |
| `weekly_report.riv` | Weekly insight hero |
| `family_care.riv` | Caregiver/family mode |

### 11.5 Animation performance requirements

- Rive animations should be paused when not visible.
- Avoid excessive looping animation.
- Prefer small file size.
- Use state machines only when necessary.
- Ensure animations do not cause frame drops on mid-range Android devices.
- Provide reduced-motion fallback in future accessibility settings.

---

## 12. User Stories

### 12.1 Routine creation

As a user, I want to create a daily routine so that I can remember important activities.

Acceptance criteria:

- User can enter routine name.
- User can choose category.
- User can choose reminder time.
- User can save routine.
- Saved routine appears in Today and Routines screen.

### 12.2 Reminder

As a user, I want to receive local reminders so that I do not forget my routine.

Acceptance criteria:

- App schedules notification at selected time.
- Notification appears even if app is closed.
- User can open app from notification.
- Routine remains visible in Today screen.

### 12.3 Mark as done

As a user, I want to mark a routine as done so that I can track my daily progress.

Acceptance criteria:

- User can tap done.
- Routine status changes to done.
- Daily progress updates.
- Checkmark animation plays.

### 12.4 Skip routine

As a user, I want to skip a routine when it is not relevant today.

Acceptance criteria:

- User can skip pending routine.
- Routine status changes to skipped.
- Progress calculation handles skipped status clearly.

### 12.5 View progress

As a user, I want to see my daily progress so that I know how consistent I am today.

Acceptance criteria:

- Today screen displays completion percentage.
- Completed and pending count are visible.
- Progress updates after status change.

### 12.6 Use without account

As a privacy-conscious user, I want to use the app without creating an account.

Acceptance criteria:

- App does not require login.
- User can use all MVP features offline.
- Data is stored locally.

### 12.7 Export data

As a user, I want to export my data so that I can back it up manually.

Acceptance criteria:

- User can export data as JSON.
- Export includes routines and history.
- User can save/share backup file.

---

## 13. Functional Requirements

### 13.1 Routine Management

The system must allow users to:

- Create routine
- Edit routine
- Delete routine
- Enable/disable routine
- Assign category
- Set reminder time
- Set repeat rule
- Add notes

### 13.2 Notification Scheduling

The system must:

- Request notification permission
- Schedule local notifications
- Cancel notification when routine is deleted
- Update notification when routine schedule changes
- Handle timezone/device time changes as gracefully as possible

### 13.3 Daily Routine Instances

The system must:

- Generate daily routine instances from active routines
- Track status per day
- Reset daily checklist
- Maintain historical logs

### 13.4 Progress Calculation

The system must calculate:

- Total routines today
- Completed routines
- Pending routines
- Skipped routines
- Missed routines
- Completion percentage

### 13.5 Settings

The system must support:

- Language selection
- Theme selection
- Notification permission status
- Backup/export
- Privacy information
- About/open-source links

---

## 14. Non-Functional Requirements

### 14.1 Performance

- App should open quickly.
- Today screen should render smoothly.
- Routine list should support at least 100 routines without noticeable lag.
- Animations should run smoothly on mid-range Android devices.

### 14.2 Reliability

- Local data must not be lost unexpectedly.
- Notification scheduling should be resilient.
- Export/import should validate data.

### 14.3 Privacy

- No account required for MVP.
- No third-party analytics in initial open-source version.
- No selling user data.
- No unnecessary permissions.

### 14.4 Accessibility

- Large enough touch targets.
- Good contrast.
- Text scaling support.
- Icons should not be the only source of meaning.
- Future reduced-motion setting.

### 14.5 Maintainability

- Clean Architecture.
- Clear module boundaries.
- Testable business logic.
- Documentation for contributors.

---

## 15. Technical Requirements

## 15.1 Recommended Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter |
| Language | Dart |
| State management | BLoC / Cubit |
| Architecture | Clean Architecture |
| Local database | Drift or Sqflite |
| Local notification | flutter_local_notifications |
| Animation | Rive |
| Vector asset | SVG |
| Localization | Flutter intl / easy_localization |
| Routing | go_router |
| Testing | flutter_test, bloc_test, mocktail |
| CI | GitHub Actions |

### Database recommendation

Recommended: **Drift** for stronger type safety and query structure.

Alternative: **Sqflite** if the project wants to stay simple and familiar.

For portfolio quality, Drift is slightly more impressive because it gives a cleaner local database layer.

## 15.2 Suggested Project Structure

```text
lib/
├── app/
│   ├── app.dart
│   ├── router.dart
│   └── theme/
├── core/
│   ├── errors/
│   ├── localization/
│   ├── notifications/
│   ├── database/
│   ├── utils/
│   └── widgets/
├── features/
│   ├── onboarding/
│   │   ├── presentation/
│   │   └── data/
│   ├── today/
│   │   ├── presentation/
│   │   ├── application/
│   │   ├── domain/
│   │   └── data/
│   ├── routines/
│   │   ├── presentation/
│   │   ├── application/
│   │   ├── domain/
│   │   └── data/
│   ├── insights/
│   │   ├── presentation/
│   │   ├── application/
│   │   ├── domain/
│   │   └── data/
│   └── settings/
│       ├── presentation/
│       ├── application/
│       ├── domain/
│       └── data/
└── main.dart
```

## 15.3 Architecture Direction

Each feature should be divided into:

- Presentation
- Application/BLoC
- Domain
- Data

### Domain examples

- `Routine`
- `RoutineSchedule`
- `RoutineLog`
- `RoutineStatus`
- `RoutineCategory`
- `ReminderRule`

### Use case examples

- `CreateRoutineUseCase`
- `UpdateRoutineUseCase`
- `DeleteRoutineUseCase`
- `GetTodayRoutinesUseCase`
- `MarkRoutineDoneUseCase`
- `SkipRoutineUseCase`
- `ScheduleRoutineNotificationUseCase`
- `CalculateDailyProgressUseCase`

---

## 16. Data Model Draft

## 16.1 Routine

```text
Routine
- id: String
- name: String
- category: RoutineCategory
- iconKey: String?
- notes: String?
- isActive: Boolean
- createdAt: DateTime
- updatedAt: DateTime
```

## 16.2 RoutineSchedule

```text
RoutineSchedule
- id: String
- routineId: String
- timeOfDay: String
- repeatType: RepeatType
- selectedWeekdays: List<Int>?
- timezone: String?
- isEnabled: Boolean
```

## 16.3 RoutineLog

```text
RoutineLog
- id: String
- routineId: String
- date: Date
- scheduledTime: DateTime
- completedAt: DateTime?
- status: RoutineStatus
- skipReason: String?
- createdAt: DateTime
- updatedAt: DateTime
```

## 16.4 Enums

```text
RoutineCategory
- meal
- water
- vitamin
- medicine
- sleep
- exercise
- breakTime
- custom

RoutineStatus
- pending
- done
- skipped
- missed
- snoozed

RepeatType
- daily
- weekdays
- customDays
```

---

## 17. Open Source Strategy

## 17.1 Repository Goals

GitHub repo must look professional and recruiter-friendly.

Required repo files:

```text
README.md
LICENSE
CONTRIBUTING.md
CODE_OF_CONDUCT.md
CHANGELOG.md
SECURITY.md
ROADMAP.md
docs/
  architecture.md
  design-system.md
  animation-guidelines.md
  product-requirements.md
  contribution-guide.md
.github/
  workflows/
  ISSUE_TEMPLATE/
  PULL_REQUEST_TEMPLATE.md
```

## 17.2 README Requirements

README should include:

- Product description
- Screenshots
- Demo GIF/video link
- Features
- Tech stack
- Architecture overview
- How to run
- Testing command
- Roadmap
- Contribution guide
- License
- Support/donation link later

## 17.3 License Recommendation

Recommended license: **Apache 2.0**.

Reason:

- Professional
- Company-friendly
- Suitable for open-source portfolio
- Better patent protection than MIT
- Easy for global contributors to understand

Alternative: MIT if the project wants maximum simplicity.

## 17.4 Brand Protection

Even if code is open source, the official brand should be protected.

Suggested rule:

> The source code is open source, but the OpenLife Routine name, logo, app icon, official store listing, and official cloud service are reserved for the official project.

This prevents confusion if someone forks the app.

---

## 18. Monetization Strategy

Monetization is not part of MVP, but the product should be designed with future monetization in mind.

### 18.1 Free open-source core

Always free:

- Local routine management
- Local reminder
- Daily checklist
- Basic progress
- Local database
- Manual backup/export

### 18.2 Future paid features

Potential Pro features:

- Cloud sync
- Encrypted cloud backup
- Multi-device sync
- Family/caregiver mode
- Advanced analytics
- Premium templates
- Widgets
- PDF/CSV report
- Web dashboard

### 18.3 Business model direction

Recommended long-term model:

1. Free open-source core
2. Paid official cloud sync
3. Family plan
4. Premium routine templates
5. B2B coach/clinic dashboard
6. Custom white-label implementation
7. GitHub Sponsors/Open Collective donation

### 18.4 Important monetization rule

Do not monetize through:

- Selling health data
- Aggressive ads
- Blocking basic reminders behind paywall
- Medical claims
- Dark patterns

---

## 19. Success Metrics

## 19.1 Product metrics

For MVP:

- User can create first routine in under 1 minute.
- Notification works reliably in local testing.
- User can complete daily checklist.
- App works offline.
- App has no critical data-loss bug.

## 19.2 Open-source metrics

First 3 months target:

- 100+ GitHub stars
- 10+ forks
- 5+ external issues
- 3+ external contributors or discussions
- 1 demo video
- 1 published APK release
- Complete README and docs

## 19.3 Career metrics

- Project added to CV and LinkedIn.
- Project used in freelance proposal.
- Project used in remote job application.
- At least 5 targeted applications per week using this project as case study.

---

## 20. MVP Milestones

## Milestone 1 — Foundation

Deliverables:

- Flutter project setup
- Clean Architecture structure
- Theme system
- Routing
- Localization setup
- Basic design tokens
- GitHub repo docs

## Milestone 2 — Routine Core

Deliverables:

- Create routine
- Edit routine
- Delete routine
- Routine list
- Routine categories
- Local database

## Milestone 3 — Today Checklist

Deliverables:

- Today screen
- Daily routine instances
- Mark done
- Skip
- Progress calculation
- Empty state

## Milestone 4 — Notification Engine

Deliverables:

- Notification permission
- Schedule local reminder
- Cancel/update reminder
- Notification tap handling
- Snooze basic

## Milestone 5 — Rive and UI Polish

Deliverables:

- Rive onboarding animation
- Rive empty state
- Rive checkmark/completion animation
- Micro-interaction polish
- Light/dark mode polish

## Milestone 6 — Portfolio Release

Deliverables:

- README final
- Screenshots
- Demo video/GIF
- APK release
- Architecture docs
- Roadmap docs
- GitHub Actions CI

---

## 21. Risks and Mitigations

| Risk | Impact | Mitigation |
|---|---|---|
| Scope terlalu besar | Project tidak selesai | Batasi MVP ke local-first routine app |
| Notification tidak reliable di beberapa Android device | User kecewa | Dokumentasikan battery optimization, test beberapa device |
| App terlihat seperti reminder biasa | Value kurang kuat | Fokus pada routine flow, checklist, progress, dan UX |
| Animasi terlalu berat | Performance turun | Pakai Rive hanya untuk momen penting |
| Open source di-copy orang | Kekhawatiran bisnis | Lindungi brand, official app, dan future cloud service |
| Monetisasi terlalu cepat | Trust turun | Tunda monetisasi sampai core app berguna |
| Terlalu medical | Risiko klaim kesehatan | Positioning sebagai routine support, bukan medical advice |

---

## 22. Future Roadmap

## Version 1.0 — MVP Public Release

- Local routine management
- Local notifications
- Today checklist
- Daily progress
- Rive animations
- English + Indonesian
- Manual backup/export
- Open-source docs

## Version 1.1 — Better Routine Experience

- Routine templates
- 7-day history
- Improved snooze
- Skip reason
- Search/filter routines
- Better empty states

## Version 1.2 — Smart Reminder Engine

- Escalation reminders
- Dependent reminders
- Quiet hours
- Routine sequence
- End-of-day summary

## Version 1.3 — Insights

- Weekly report
- Monthly report
- Completion trends
- Most missed routine
- Streak
- Export CSV/PDF

## Version 2.0 — Family/Caregiver Mode

- Multi-profile
- Shared routines
- Caregiver view
- Family reminder escalation
- Family progress summary

## Version 3.0 — Optional Cloud Layer

- Account
- Encrypted cloud backup
- Multi-device sync
- Family sharing
- Web dashboard
- Subscription-ready backend

## Version 4.0 — B2B/Coach Mode

- Coach dashboard
- Routine template builder
- Assign routine to client
- Progress report
- White-label option

---

## 23. Positioning for Portfolio

OpenLife Routine should be presented as:

> A production-ready open-source Flutter application demonstrating Clean Architecture, BLoC, local-first persistence, local notifications, Rive animations, and privacy-first product design.

### Portfolio pitch

> I built OpenLife Routine as an open-source Flutter app to help people manage daily routines, medication/supplement reminders, hydration, meals, and lifestyle checklists. The app is offline-first, privacy-first, and built with Clean Architecture, BLoC, local database, local notifications, and Rive animations.

### Freelance pitch

> I can build production-ready Flutter apps with offline-first architecture, local database, reminders, clean UI, and scalable code structure. OpenLife Routine is my open-source proof of work.

---

## 24. Definition of Done for MVP

MVP is considered done when:

- User can complete onboarding.
- User can create a routine.
- User can schedule local reminder.
- User receives notification.
- User can mark routine as done.
- Today progress updates correctly.
- Data persists after app restart.
- App works without internet.
- Rive animations are integrated in key screens.
- README is complete.
- Architecture docs are available.
- APK release is available on GitHub.
- Basic tests pass in CI.

---

## 25. Final Product Direction

OpenLife Routine must stay focused on this core promise:

> Help people build better days through simple, private, and consistent daily routines.

The product should not try to become a full medical app, social network, AI coach, or complex productivity suite too early.

The best version of OpenLife Routine is:

- Simple enough for daily use
- Beautiful enough for portfolio
- Useful enough for real users
- Open enough for community
- Structured enough for recruiters
- Flexible enough for future monetization

---

## 26. Immediate Next Step

After this PRD, the recommended next documents are:

1. `roadmap.md`
2. `sprint-planning.md`
3. `architecture.md`
4. `design-system.md`
5. `animation-guidelines.md`
6. `github-repo-setup.md`

The next build step should be:

> Create Flutter project foundation with Clean Architecture, BLoC, theme tokens, routing, localization, local database setup, and first Today screen skeleton.
