# ADR-0004: Use Full BLoC (No Cubit)

**Date:** 2026-07-02
**Status:** Accepted

## Context

OpenLife Routine needs predictable state management across features. The `flutter_bloc` package offers two APIs:

1. **Cubit** — simpler, fewer boilerplate, event-driven via method calls.
2. **BLoC** — full event-driven pattern with `Event` and `State` classes.

## Decision

We chose **full BLoC** (no Cubit) for the entire project.

## Rationale

- **Predictability**: Every state transition is triggered by an explicit event, making debugging and testing straightforward.
- **Portfolio value**: Full BLoC demonstrates stronger architectural understanding to recruiters and clients.
- **Consistency**: Using one pattern throughout avoids confusion for contributors.
- **Testability**: `blocTest` from `bloc_test` package works seamlessly with full BLoC.
- **Project rule**: The `sprint-checklist.md` explicitly states "Use full BLoC only. Do not use Cubit."

## Consequences

- **Positive**: Clear event→state traceability, excellent test coverage, consistent codebase.
- **Negative**: More boilerplate per feature (separate Event, State, and Bloc files).
- **Neutral**: Steeper learning curve for beginners, but better for maintainability.

## Alternatives Considered

- **Cubit**: Simpler but lacks the explicit event layer that aids debugging.
- **Provider + ChangeNotifier**: Less structured, harder to test at scale.
- **Riverpod**: Powerful but less widely adopted in enterprise Flutter.

## References

- [flutter_bloc documentation](https://bloclibrary.dev/)
- [Sprint Checklist Rule](../../document-openlife/sprint-checklist.md)
