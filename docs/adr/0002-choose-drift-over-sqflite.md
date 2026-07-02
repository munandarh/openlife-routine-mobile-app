# ADR-0002: Use Drift over sqflite for Local Database

**Date:** 2026-07-02
**Status:** Accepted

## Context

OpenLife Routine needs a local database to store routines, schedules, and logs. Two options were considered:

1. **sqflite** — the most common Flutter SQLite wrapper, simple API.
2. **Drift** (formerly moor) — a reactive persistence library with type-safe queries, migrations, and stream-based reactivity.

## Decision

We chose **Drift** for the following reasons:

- **Type-safe queries**: Compile-time checked SQL queries reduce runtime errors.
- **Built-in migrations**: Schema versioning is built into the API.
- **Reactive streams**: Drift tables can be watched as Dart streams, which integrates naturally with BLoC.
- **Portfolio value**: Drift demonstrates stronger engineering discipline for open-source and recruiter evaluation.

## Consequences

- **Positive**: Fewer runtime SQL errors, cleaner repository code, automatic code generation.
- **Negative**: Requires `build_runner` code generation step, slightly larger build times.
- **Neutral**: The Drift API surface is larger but well-documented.

## Alternatives Considered

- **sqflite**: Simpler but less type-safe. Would require manual query building.
- **Hive**: NoSQL key-value store. Not suitable for relational data with joins.
- **ObjectBox**: High-performance but adds native dependencies and reduces portability.

## References

- [Drift documentation](https://drift.simonbinder.eu/)
- [PRD §15 — Technical Requirements](../PRD.md)
