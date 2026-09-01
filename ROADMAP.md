# Roadmap

Where OpenLife Routine is going. Dates are intentionally absent — this is a
side project, and shipping order matters more than shipping dates.

Scope decisions trace back to [`docs/PRD.md`](docs/PRD.md) §22.

---

## v1.0 — MVP ✅

Everything in PRD §7.1 is implemented.

- Onboarding: language → notification permission → 3 value slides → starter
  template picker
- Routine CRUD with 8 categories, icon override, notes, per-routine snooze
- Today checklist: progress ring, next-routine card, done / skip / snooze /
  undo, missed state
- Local reminders: weekly scheduling, snooze, cancel and rebuild on change,
  timezone-aware, deep link on tap
- Insights: weekly completion, daily chart, streak, most completed / most
  missed, 7-day history
- 5 starter templates
- Settings: theme, language, reduced motion, JSON export/import, reset
- English + Indonesian throughout, including notification copy
- Light and dark themes
- Offline-first, no account, no analytics

**Known gaps carried into v1.1:** no `.riv` animations (PNG illustrations ship
instead), no store release, no iOS device testing.

---

## v1.1 — Polish the routine experience

- Real Rive animations for the six MVP entries already declared in
  `OpenLifeAnimationAssets`
- Skip reason ("not today", "already done elsewhere")
- Search and filter on the Routines list
- Reorder routines within a day
- Duplicate a routine
- Widen reduced motion to cover every non-essential animation
- Play Store internal testing track

---

## v1.2 — Smarter reminders

The reminder engine from PRD §8.4 "future behavior".

- Escalating reminders when a routine goes unanswered
- Dependent reminders (`after Breakfast is done, remind Vitamin D3 in 15 min`)
- Quiet hours
- Routine sequences
- End-of-day summary notification
- Background missed-state sweep via `WorkManager`, replacing the launch-time job

---

## v1.3 — Deeper insights

- Monthly report
- Completion trends over time
- Per-category breakdown
- Consistency score
- CSV and PDF export
- Home-screen widget

---

## v2.0 — Family / caregiver mode

- Multiple profiles on one device
- Shared routines
- Caregiver view of another profile's day
- Family progress summary

Still local-first: profiles live on the device.

---

## v3.0 — Optional cloud layer

Opt-in, never required.

- Account (optional)
- End-to-end encrypted backup
- Multi-device sync
- Web dashboard

The free, offline, no-account core stays free and offline. Cloud is an
addition, not a gate.

---

## v4.0 — Coach / B2B

- Coach dashboard
- Routine template builder
- Assign routines to a client
- Progress reports
- White-label option

---

## Permanently out of scope

Not "later" — no.

- Medical diagnosis, treatment advice, or health claims
- Selling or sharing user data
- Ads
- Putting basic reminders behind a paywall
- Social feed, following, public profiles
- Aggressive engagement mechanics (streak guilt, loss-aversion nudges)

---

## Contributing to the roadmap

Open a discussion rather than a pull request for a new roadmap item. For
anything already listed, see
[`docs/contribution-guide.md`](docs/contribution-guide.md).
