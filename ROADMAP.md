# Roadmap — OpenLife Routine

> Derived from [`docs/PRD.md`](docs/PRD.md) §22. Status reflects what is in the
> code, verified against `lib/`, not what a sprint was named after. Day-to-day
> progress lives in [`docs/SPRINT-CHECKLIST.md`](docs/SPRINT-CHECKLIST.md).

Legend: ✅ shipped · 🚧 in progress · ⬜ not started

---

## v1.0 — MVP Public Release

The MVP is judged against the Definition of Done in PRD §24, not against a
feature count. Ten of its thirteen criteria are met.

| Area | Status | Notes |
|---|---|---|
| Local routine management | ✅ | Create, edit, delete, categories, notes |
| Local notifications | ✅ | Weekly schedule, snooze, timezone, tap-to-open |
| Today checklist | ✅ | Pending, done, skipped, snoozed, missed |
| Daily progress | ✅ | Completion percentage and counts |
| English + Indonesian | 🚧 | Delegate registered; first-run and Settings localized, remaining screens still hardcoded English |
| Manual backup/export | ✅ | JSON export, import, validation |
| Open-source docs | 🚧 | README, CONTRIBUTING, SECURITY, CHANGELOG, 5 ADRs, architecture doc done; design-system and animation guidelines outstanding |
| Rive animations | ⬜ | `OpenLifeRiveView` and the PNG fallback layer are in place; no `.riv` files have been produced |
| APK on GitHub Releases | ⬜ | Requires a signed build |

### Remaining for v1.0

1. Produce the `.riv` files for the key moments (onboarding hero, empty state,
   completion check) — PRD §7.1 lists this as P0.
2. Finish the localization pass on Today, Routines, Templates, Insights, New
   Routine and Routine Detail.
3. `docs/design-system.md` and `docs/animation-guidelines.md`.
4. Screenshots and a demo recording from a real device.
5. Publish the release APK.

## v1.1 — Better Routine Experience

| Item | Status |
|---|---|
| Routine templates | ✅ five seed templates, applied from Templates and from onboarding |
| 7-day history | 🚧 weekly chart, streak and most completed/missed exist; the full summary screen does not |
| Improved snooze | ✅ shared scheduling path, log status persisted |
| Icon override per routine | ⬜ optional field in PRD §8.3; needs `Routine.iconKey`, schema v3, export/import and a picker |
| End-of-day job | ⬜ the flip to `missed` runs at next launch, not at midnight; needs background execution |
| Skip reason | ⬜ |
| Search / filter routines | ⬜ |
| Better empty states | ✅ illustrated empty states across Today, Routines, Templates, Insights |

## v1.2 — Smart Reminder Engine

⬜ Escalation reminders · dependent reminders · quiet hours · routine sequences
· end-of-day summary.

## v1.3 — Insights

⬜ Weekly and monthly reports · completion trends · CSV/PDF export.
Most-missed routine and streak already ship in v1.0.

## v2.0 — Family / Caregiver Mode

⬜ Multi-profile · shared routines · caregiver view · family escalation and
progress summary.

## v3.0 — Optional Cloud Layer

⬜ Accounts · encrypted backup · multi-device sync · web dashboard.

Cloud stays optional. The local database remains the source of truth, so the
app keeps working with the network turned off (PRD §6.2).

## v4.0 — B2B / Coach Mode

⬜ Coach dashboard · template builder · assign routines to a client · progress
reports · white-label.

---

## Explicitly out of scope

These are not "later", they are decisions (PRD §7.2). Login and register,
cloud sync in v1, AI coach, web dashboard, subscriptions, a B2B clinic
dashboard, medical diagnosis, smartwatch integration, a push notification
server, social features, and a community feed.

The app is a routine support tool. It does not diagnose, treat, or claim to
cure anything.
