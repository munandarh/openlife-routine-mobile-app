# OpenLife Routine

OpenLife Routine is an open-source Flutter mobile app for managing daily routines such as meals, water, vitamins, medicine, sleep, exercise, and breaks. The product direction is privacy-first, offline-first, and calm by design.

## Current Status

This repository is in `Sprint 0 — Foundation`.

Implemented so far:

- Flutter project scaffold in repo root
- Full BLoC direction locked for state management
- `go_router` baseline with 4-tab MVP shell
- Theme token foundation for Calm Daily Companion
- Sprint execution checklist for tracked progress
- Flutter analyze/test CI workflow baseline

## MVP Navigation

The MVP app shell uses 4 primary tabs:

1. Today
2. Routines
3. Insights
4. Settings

`Templates` is part of the `Routines` flow, not a bottom-navigation tab.

## Tech Direction

- Flutter
- Full BLoC via `flutter_bloc`
- `go_router`
- Offline-first local storage
- Local notifications
- Calm, rounded design system based on project docs in `document-openlife/`

## Project Structure

```text
lib/
  app/
  core/
  features/
  shared/
document-openlife/
ui-ux-design-screen/
test/
```

## Run

```bash
flutter pub get
flutter run
```

## Validate

```bash
flutter analyze
flutter test
```

## Key Documents

- `document-openlife/PRD.md`
- `document-openlife/design.md`
- `document-openlife/design-system.md`
- `document-openlife/architecture.md`
- `document-openlife/roadmap.md`
- `document-openlife/sprint-planning.md`
- `document-openlife/sprint-checklist.md`

## Contribution

This project is being built incrementally. Before changing architecture or UX direction, align with the product and design documents first.
