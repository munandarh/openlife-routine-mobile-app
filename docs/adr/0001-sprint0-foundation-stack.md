# ADR 0001: Sprint 0 Foundation Stack

## Status

Accepted

## Context

Sprint 0 needs foundation decisions that unblock the next implementation sprints without overbuilding.

The project already locked these product rules:

- Full BLoC only, no Cubit
- MVP bottom navigation: `Today / Routines / Insights / Settings`
- `Templates` belongs to the `Routines` flow
- Offline-first and privacy-first are non-negotiable

## Decision

### State management

- Use `flutter_bloc`
- Use full `Bloc` classes only
- Do not introduce `Cubit`

### Routing

- Use `go_router`
- Keep a single app shell for the 4 MVP tabs

### Local database

- Lock `drift` as the local database layer
- Use `sqlite3_flutter_libs` as the SQLite runtime support package
- Delay actual schema and DAO implementation until Sprint 3

### Notifications

- Lock `flutter_local_notifications` for local reminders
- Lock `timezone` for timezone-safe scheduling
- Delay scheduler implementation until Sprint 5

### Dependency injection

- Use manual dependency wiring for now
- `AppDependencies` + `AppScope` is enough for the MVP baseline
- Do not add a DI framework unless manual wiring becomes painful

## Consequences

- Sprint 1 can focus on UI shell and design tokens without reopening stack choices
- Sprint 3 can start directly on Drift models/tables
- Sprint 5 can start directly on notification scheduling
- We avoid premature `get_it` or `injectable` complexity
