# ADR 0006 — Close out missed days at launch, not in the background

- **Status:** Accepted
- **Date:** 2026-09-01
- **Supersedes:** the original "mark yesterday's pending logs as missed" job

## Context

PRD §8.5 requires a routine that is not completed by the end of its day to
become `missed`. The MVP has no server and no background worker, so something
has to notice that a day ended.

The first implementation ran once at launch and only looked at yesterday. That
is correct exactly when the user opens the app every single day. Skip a
weekend and Saturday and Sunday stay `pending` forever, which quietly corrupts
Insights: those days count in neither the completed nor the missed column.

It also only rewrote rows that already existed with status `pending`. Nothing
in the app writes a `pending` row — pending is represented by the *absence* of
a log — so on a normal install the job matched nothing at all.

## Options considered

1. **`WorkManager` / `AlarmManager` job at midnight.** Most precise. Costs a
   platform dependency, an Android-only code path, battery-optimisation
   handling on OEM builds, and a scheduling surface that is hard to test.
2. **Derive `missed` purely in the UI.** No writes, always correct on screen.
   But Insights aggregates over logs, so "missed" would have to be recomputed
   from schedules in every query, and history would have no durable record.
3. **A catch-up sweep at launch.** Runs in `bootstrap()` before the first
   frame, walks from a persisted watermark to yesterday, and writes a `missed`
   log for every scheduled routine with no final answer.

## Decision

Option 3, with option 2 as a display-time safety net.

`MissedStateService.sweepMissedDays(since:)`:

- starts at the last recorded sweep date + 1 day, not at yesterday, so it
  catches up on every missed day;
- treats only `done`, `skipped` and `missed` as final — a leftover `pending` or
  `snoozed` row on a finished day is exactly what "missed" means and gets
  overwritten;
- respects each routine's `repeatDays`, so a weekdays-only routine is never
  marked missed on a Sunday;
- is capped by `maxLookbackDays` (30) so a stale install does not write a year
  of rows on launch;
- records **yesterday** as the new watermark. Recording *today* would make
  tomorrow's run start after today and skip it forever.

Independently, `TodayBloc` renders a past day with no log as `missed`, so the
UI is right even before the sweep has written the row.

## Consequences

**Good**

- Correct after any gap in usage, which is the normal case for a habit app.
- No platform-specific scheduling code, no battery-optimisation exceptions to
  ask users for.
- Fully testable with an injected clock; the behaviour is covered by
  `missed_state_service_test.dart` and `bootstrap_test.dart`.

**Bad**

- A day is only closed out when the app is next opened, so a notification
  cannot say "you missed 3 routines yesterday" until launch.
- The sweep is on the startup path. It is bounded and short-circuits once the
  cursor reaches today, but it is not free.
- More than 30 days away and the gap is left unlogged rather than backfilled.

## Revisit when

v1.2 introduces the smart reminder engine. An end-of-day summary notification
needs a real background job anyway; the sweep should move into it then, keeping
the launch-time run as the fallback for when the OS drops the job.
