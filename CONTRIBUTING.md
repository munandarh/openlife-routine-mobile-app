# Contributing

## Working Rules

- Follow the product and design docs in `document-openlife/`.
- Keep MVP scope strict.
- Use full BLoC. Do not introduce Cubit.
- Keep `Templates` inside the `Routines` flow for MVP.
- Prefer small, testable changes.

## Validation

Run before proposing changes:

```bash
flutter analyze
flutter test
```
