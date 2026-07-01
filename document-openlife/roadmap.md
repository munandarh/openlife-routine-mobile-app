# OpenLife Routine — Roadmap

> **Product:** OpenLife Routine  
> **Type:** Open-source Flutter mobile app  
> **Design concept:** Calm Daily Companion  
> **Architecture:** Offline-first, privacy-first, Clean Architecture, BLoC  
> **Animation:** Rive for purposeful onboarding, empty states, reminder states, and celebration  
> **Roadmap Version:** v1.0

---

## 1. Roadmap Purpose

This roadmap defines the staged development plan for **OpenLife Routine**, an open-source daily routine reminder app for meals, water, vitamins, medicine, sleep, exercise, breaks, and lifestyle checklists.

The main objective is to build a polished, production-quality open-source portfolio project that can also grow into a long-term monetizable product.

The roadmap prioritizes:

1. Shipping a small but useful MVP.
2. Demonstrating strong Flutter engineering quality.
3. Keeping the app offline-first and privacy-first.
4. Building a design system that looks modern and professional.
5. Using Rive animation with purpose, not decoration.
6. Preparing future monetization without damaging open-source trust.

---

## 2. Product North Star

> Help users build better days, one routine at a time.

OpenLife Routine should become a calm daily companion that helps users remember, complete, and understand their daily routines without pressure.

The app should feel:

- Simple
- Helpful
- Warm
- Trustworthy
- Private
- Offline-first
- Modern
- Portfolio-quality

---

## 3. Roadmap Strategy

The project will be built in layers:

1. **Foundation first** — project structure, architecture, design system, docs.
2. **Core utility second** — routine creation, daily checklist, local data.
3. **Reminder reliability third** — local notification engine and reminder logs.
4. **Polish fourth** — animation, micro-interactions, accessibility, tests.
5. **Public release fifth** — GitHub, APK, docs, demo video, portfolio case study.
6. **Growth later** — templates, advanced analytics, sync, family/caregiver, monetization.

---

## 4. Release Phases

## Phase 0 — Project Foundation

**Goal:** Prepare the project as a serious open-source portfolio repo.

### Scope

- Create Flutter project.
- Setup GitHub repository.
- Setup folder structure.
- Add documentation foundation.
- Add linting and formatting rules.
- Add CI workflow.
- Add design tokens.
- Add base theme.
- Add routing.
- Add app localization foundation.
- Add placeholder Rive integration.

### Deliverables

- `README.md`
- `roadmap.md`
- `sprint-planning.md`
- `architecture.md`
- `design-system.md`
- `animation-guidelines.md`
- `contributing.md`
- `code_of_conduct.md`
- GitHub issue templates
- GitHub Actions CI
- Initial Flutter app shell

### Success Criteria

- Project runs on Android emulator.
- Basic app shell is visible.
- Linting passes.
- CI runs on pull request.
- Docs are readable and professional.

---

## Phase 1 — UI Prototype and Design System

**Goal:** Build the visual foundation based on the Calm Daily Companion concept.

### Scope

- Onboarding screen prototype.
- Today dashboard prototype.
- New Routine form prototype.
- Routine Detail prototype.
- Insights screen prototype.
- Templates screen prototype.
- Settings screen prototype.
- Bottom navigation.
- Week date selector.
- Routine cards.
- Progress ring component.
- Empty state component.
- Primary CTA button.
- Floating add button.
- Light and dark theme.

### Deliverables

- Reusable UI components.
- Design token implementation.
- Responsive layout behavior.
- Basic Rive placeholder areas.
- Screenshot-ready UI.

### Success Criteria

- App visually matches the Calm Daily Companion direction.
- UI feels modern, soft, and polished.
- No business logic is required yet.
- Screens can be used for portfolio screenshots.

---

## Phase 2 — Routine Core MVP

**Goal:** Allow users to create, edit, view, and delete routines locally.

### Scope

- Routine model.
- Routine categories:
  - Meal
  - Water
  - Vitamin
  - Medicine
  - Sleep
  - Exercise
  - Break
  - Custom
- Routine CRUD.
- Repeat days.
- Reminder time.
- Routine status.
- Local database.
- Today routine filtering.
- Mark as done.
- Skip routine.
- Daily routine logs.

### Deliverables

- Routine creation works.
- Today screen uses real data.
- Daily progress uses real completion data.
- Local persistence works after app restart.

### Success Criteria

- User can create a routine in less than 1 minute.
- User can complete a routine in 1 tap.
- Today screen accurately displays current day routines.
- Data is saved locally.

---

## Phase 3 — Reminder Engine MVP

**Goal:** Build reliable local reminders.

### Scope

- Notification permission flow.
- Local notification scheduling.
- Reminder trigger at selected time.
- Snooze action.
- Done action from notification where platform allows.
- Reminder log.
- Basic escalation rule:
  - remind once
  - snooze manually
  - optionally repeat if not completed
- Quiet hours setting.
- Timezone-safe scheduling.

### Deliverables

- Local notifications work on Android.
- Routine reminders are scheduled after creation.
- Reminder updates when routine changes.
- Reminder cancels when routine is disabled or deleted.

### Success Criteria

- Notifications trigger at correct time.
- Rescheduling works after app restart.
- No duplicate notification spam.
- Missed/completed logs are accurate enough for MVP.

---

## Phase 4 — Rive Animation and UX Polish

**Goal:** Add meaningful motion and micro-interactions.

### Scope

- Onboarding Rive animation.
- Empty state animation.
- Reminder active animation.
- Check done animation.
- Daily complete celebration animation.
- Smooth progress animation.
- Screen transitions.
- Button feedback.
- Loading skeletons.
- Haptic feedback for important actions.

### Deliverables

- Rive assets integrated.
- Animation guidelines implemented.
- Fallback UI available if animation fails.
- Motion is soft and not distracting.

### Success Criteria

- Animations improve clarity and delight.
- No major performance issues.
- App remains smooth on mid-range Android devices.

---

## Phase 5 — Insights, Templates, and Backup

**Goal:** Make the app more useful for daily and weekly tracking.

### Scope

- 7-day history.
- Weekly completion rate.
- Most completed routine.
- Most missed routine.
- Routine streak.
- Routine templates.
- Import/export JSON backup.
- Basic privacy screen.
- Data reset option.

### Deliverables

- Insights screen uses real logs.
- User can start from a template.
- User can export and import local data.

### Success Criteria

- Insights are easy to understand.
- Templates reduce setup friction.
- Backup file can restore routines and logs.

---

## Phase 6 — Public MVP Release

**Goal:** Release the first public open-source version.

### Scope

- Final bug fixing.
- README polish.
- Screenshots.
- Demo video.
- GitHub release APK.
- Contribution guide.
- Known limitations page.
- Roadmap update.
- App icon.
- Store listing draft.

### Deliverables

- GitHub release `v1.0.0-mvp`.
- APK downloadable from GitHub Releases.
- Public README with screenshots.
- Portfolio case study.

### Success Criteria

- A recruiter or client can run the app and understand the architecture.
- The repo looks professional.
- The app is useful as a real daily routine app.
- MVP is stable enough for personal use.

---

## 5. Post-MVP Roadmap

## v1.1 — Quality and Community Release

### Scope

- Improve tests.
- Add more routine templates.
- Add Indonesian and English translation polish.
- Add accessibility improvements.
- Add issue templates.
- Add beginner-friendly contribution labels.
- Add F-Droid preparation checklist.

### Goal

Make the app friendly for open-source contributors.

---

## v1.2 — Advanced Reminder Rules

### Scope

- Dependent reminders.
- Example: after meal is done, remind vitamin after 15 minutes.
- Multiple reminders per routine.
- Escalation reminder.
- Reminder priority.
- Custom snooze duration.
- Missed routine reason.

### Goal

Differentiate OpenLife Routine from basic alarm apps.

---

## v1.3 — Advanced Insights

### Scope

- Monthly report.
- Routine consistency score.
- Category breakdown.
- Export CSV/PDF.
- Best day of week.
- Most difficult routine.

### Goal

Help users understand patterns without overwhelming them.

---

## v1.4 — Widgets and Quick Actions

### Scope

- Android home screen widget.
- Today progress widget.
- Quick done action.
- Quick add routine.
- Notification action improvements.

### Goal

Make routine completion faster.

---

## v1.5 — Privacy and Backup Upgrade

### Scope

- Encrypted local backup.
- Auto backup to local file provider.
- Backup restore validation.
- Data portability docs.
- Privacy audit checklist.

### Goal

Strengthen trust and open-source credibility.

---

## 6. Long-Term Roadmap

## v2.0 — Optional Cloud Sync

### Scope

- Optional account system.
- End-to-end encrypted backup direction.
- Multi-device sync.
- Official hosted sync service.
- Clear privacy policy.

### Monetization Potential

Cloud sync can become a paid convenience layer while core local features remain free and open source.

---

## v2.1 — Family and Caregiver Mode

### Scope

- Multi-profile.
- Shared routines.
- Caregiver notifications.
- Family progress dashboard.
- Routine assignment.

### Monetization Potential

Family plan subscription.

---

## v2.2 — Coach and Clinic Mode

### Scope

- Web dashboard.
- Routine template builder.
- Assign template to users.
- Progress report export.
- White-label support.

### Monetization Potential

B2B plan for coaches, clinics, nutritionists, and wellness communities.

---

## v2.3 — Template Marketplace

### Scope

- Community routine templates.
- Curated premium templates.
- Category packs.
- Template rating.
- Template import/export.

### Monetization Potential

Premium template packs.

---

## 7. GitHub Portfolio Roadmap

The project should also support personal career goals.

### Portfolio Milestones

| Milestone | Purpose |
|---|---|
| Public GitHub repo | Show open-source initiative |
| Clean README | Recruiter-friendly first impression |
| Architecture docs | Show senior-level thinking |
| Design system docs | Show product/design maturity |
| Tests and CI | Show engineering discipline |
| Demo APK | Let clients test the app |
| Demo video | Improve job/freelance applications |
| Case study | Use in LinkedIn, portfolio, Upwork |
| Contribution guide | Show maintainer ability |

---

## 8. MVP Success Metrics

### Product Metrics

- User can create first routine in less than 1 minute.
- User can complete a routine in 1 tap.
- Today screen loads instantly from local database.
- Notifications trigger reliably.
- App works without login.
- App works without internet.

### Engineering Metrics

- Linting passes.
- Unit tests pass.
- Widget tests cover core screens.
- Core business logic is tested.
- CI runs on pull request.
- No critical runtime crashes in manual testing.

### Portfolio Metrics

- README has screenshots and demo video.
- Architecture is documented.
- App can be installed from GitHub release.
- Repo has clear issues and roadmap.
- Code structure is easy to understand.

---

## 9. Non-Goals for Early Versions

Do not build these too early:

- AI coach
- Medical diagnosis
- Cloud sync in MVP
- Subscription system in MVP
- B2B dashboard in MVP
- Complex social features
- Gamification-heavy mechanics
- Too many animation effects
- Forced login
- Ad-based monetization

---

## 10. Recommended First Public Version

The first public version should be:

> **OpenLife Routine v1.0.0 MVP — Offline-first daily routine reminder app with local routines, local notifications, daily checklist, progress tracking, templates, backup, and Rive-powered calm animations.**

This version is enough to prove product value and Flutter engineering quality.
