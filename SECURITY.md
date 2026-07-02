# Security Policy

## Supported Versions

| Version | Supported          |
| ------- | ------------------ |
| 1.0.x   | :white_check_mark: |

## Reporting a Vulnerability

If you discover a security vulnerability in OpenLife Routine, please **do not** open a public issue.

Instead, email the maintainer directly at:

**haris.munandar@example.com**

You can expect:
- Acknowledgment within 48 hours
- Regular updates on the progress
- Credit in the release notes (unless you prefer to remain anonymous)

## Security Design

OpenLife Routine is designed with privacy and security as first principles:

- **Offline-first**: All data is stored locally on the device using SQLite. No data is transmitted to any server.
- **No accounts**: There is no login, registration, or authentication system. No personal information is collected.
- **No analytics**: No third-party analytics, crash reporting, or tracking services are integrated.
- **Local notifications only**: Reminders are scheduled using the device's local notification system. No push notification server is involved.
- **User-controlled data**: Users can export their data as JSON, import backups, or reset all data at any time.
- **No network permissions**: The app does not request internet access for core functionality.

## Dependency Management

Dependencies are kept minimal and reviewed regularly:

- `flutter_bloc` — State management
- `drift` — Type-safe SQLite
- `flutter_local_notifications` — Local notifications
- `go_router` — Navigation
- `shared_preferences` — Key-value preferences
- `rive` — Vector animations
- `intl` / `flutter_localizations` — Internationalization

Run `flutter pub outdated` to check for dependency updates.

## Build Integrity

- All builds are reproducible from source.
- Release APKs are signed and published on GitHub Releases.
- CI runs `flutter analyze` and `flutter test` on every pull request.
