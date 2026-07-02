# OpenLife Routine

> Build better days, one routine at a time.

[![License](https://img.shields.io/badge/license-Apache%202.0-blue.svg)](LICENSE)
[![Flutter](https://img.shields.io/badge/flutter-3.x-blue)](https://flutter.dev)
[![Tests](https://img.shields.io/badge/tests-188%20passing-brightgreen)]()
[![Platform](https://img.shields.io/badge/platform-android-green)]()

**OpenLife Routine** is an open-source, privacy-first, offline-first daily routine reminder app built with **Flutter**. It helps users manage meals, water, vitamins, medicine, sleep, exercise, breaks, and lifestyle checklists — privately and consistently.

> *No accounts. No cloud. No tracking. Just calm, on-device reminders.*

---

## ✨ Features

| Feature | Description |
|---|---|
| 🏠 **Onboarding** | 5-screen flow: language selection → notification permission → 3 value slides → starter template picker |
| 📋 **Today Checklist** | Daily progress ring, mark done/skip/undo, time-based greeting with supportive subtitle |
| 🔔 **Reminders** | Local notifications with snooze, cancel/update on routine change, timezone-safe |
| 📊 **Insights** | Weekly completion rate, daily chart, most completed/missed routine, streak |
| 📦 **Templates** | 5 seed templates with one-tap apply (Morning, Hydration, Vitamin, Sleep, Programmer Break) |
| ⚙️ **Settings** | Theme (System/Light/Dark), Language (EN/ID), Export/Import JSON, Reset, Privacy, About |
| 🎨 **Animations** | Rive wrapper with PNG illustrations, progress ring, card transitions, celebration overlay |
| 🔒 **Privacy-First** | No accounts, no analytics, no tracking, data stays on-device |
| 📱 **Offline-First** | Full functionality without internet; cloud sync planned for future |

---

## 🧱 Architecture

| Layer | Technology |
|---|---|
| Framework | Flutter 3.x + Dart |
| State Management | Full BLoC (no Cubit) |
| Database | Drift SQLite (schema v2) |
| Navigation | go_router |
| Notifications | flutter_local_notifications |
| Animation | Rive (with PNG fallback) |
| DI | Manual (AppScope + AppDependencies) |
| Testing | flutter_test, bloc_test, mocktail |
| CI | GitHub Actions |

```
lib/
├── app/          # App shell + routing + theme
├── core/         # DI, localization, notifications, DB, services
├── features/     # Feature-first modules
│   ├── onboarding/
│   ├── today/
│   ├── routines/
│   ├── routine_detail/
│   ├── insights/
│   ├── templates/
│   ├── settings/
│   └── splash/
└── shared/       # Widgets, illustrations, navigation
```

📖 Full docs: [`docs/PRD.md`](docs/PRD.md) · [`docs/architecture.md`](docs/architecture.md) · [`docs/design-system.md`](docs/design-system.md)

---

## 🚀 Quick Start

```bash
# Clone
git clone https://github.com/harismunandar/openlife-routine.git
cd openlife-routine

# Install dependencies
flutter pub get

# Run code generation (Drift + l10n)
dart run build_runner build --delete-conflicting-outputs

# Run on device/emulator
flutter run

# Release build
flutter build apk --release
```

---

## 🧪 Testing

```bash
# Run all tests (188 passing)
flutter test

# Analyze
flutter analyze

# Run specific test file
flutter test test/features/today/
```

---

## 📦 Download

Download the latest APK from [GitHub Releases](https://github.com/harismunandar/openlife-routine/releases).

---

## 📖 Documentation

| Doc | Description |
|---|---|
| [`docs/PRD.md`](docs/PRD.md) | Product requirements + MVP scope |
| [`docs/SPRINT-CHECKLIST.md`](docs/SPRINT-CHECKLIST.md) | Master implementation tracker |
| [`docs/adr/`](docs/adr/) | Architecture Decision Records |
| [`CHANGELOG.md`](CHANGELOG.md) | Version history |
| [`SECURITY.md`](SECURITY.md) | Security policy |
| [`CONTRIBUTING.md`](CONTRIBUTING.md) | Contribution guide |
| [`CODE_OF_CONDUCT.md`](CODE_OF_CONDUCT.md) | Code of conduct |

---

## 🗺️ Roadmap

| Version | Focus |
|---|---|
| **v1.0.0** ✅ | MVP: routine CRUD, today checklist, reminders, insights, templates, settings, animations, i18n |
| **v1.1** | Improved snooze, skip reason, search/filter routines, better empty states |
| **v1.2** | Smart reminders: escalation, dependent reminders, quiet hours |
| **v1.3** | Monthly insights, CSV/PDF export, streak visualization |
| **v2.0** | Optional cloud sync, multi-device |
| **v2.1** | Family/caregiver mode |

---

## 🤝 Contributing

Contributions are welcome! See [`CONTRIBUTING.md`](CONTRIBUTING.md) for guidelines.  
Good first issues are tagged with `good first issue`.

---

## 📜 License

Apache License 2.0 — see [`LICENSE`](LICENSE) for details.

> *The source code is open source, but the OpenLife Routine name, logo, app icon, and official store listing are reserved for the official project.*

---

## 💼 Portfolio

OpenLife Routine was built as a production-quality open-source portfolio project to demonstrate:

- ✅ Flutter production-ready app development
- ✅ Clean Architecture with BLoC
- ✅ Offline-first local database (Drift SQLite)
- ✅ Local notification scheduling
- ✅ Rive/vector animation integration
- ✅ Full test coverage (188 tests)
- ✅ Professional documentation + ADRs
- ✅ CI/CD with GitHub Actions

> *"I built OpenLife Routine as an open-source Flutter app to help people manage daily routines, medication reminders, hydration, meals, and lifestyle checklists. The app is offline-first, privacy-first, and built with Clean Architecture, BLoC, local database, local notifications, and Rive animations."*
