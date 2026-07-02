# ADR-0005: Offline-First Core with Optional Cloud Sync Later

**Date:** 2026-07-02
**Status:** Accepted

## Context

OpenLife Routine must work without internet access (PRD §6.2). The architecture needs to support offline usage now while leaving the door open for optional cloud sync in a future version.

## Decision

All core features (routine CRUD, daily checklist, reminders, insights, settings) are **offline-first** by default. The repository interfaces are designed to allow a future `SyncRoutineRepository` without changing the domain or presentation layers.

## Implementation

- `RoutineRepository` is an abstract interface with a single `DriftRoutineRepository` implementation today.
- All data flows through the repository contract — the BLoC layer never touches the database directly.
- `AppDatabase` is the single source of truth; `ExportImportService` provides manual backup.

## Consequences

- **Positive**: Users can use the app without internet from day one.
- **Positive**: Repository interface allows swapping implementations without touching BLoC/UI.
- **Negative**: Cloud sync will require conflict resolution logic — deferred to v2.0+.

## References

- [PRD §6.2 — Offline-first](../PRD.md)
- [Architecture docs](../../document-openlife/architecture.md)
