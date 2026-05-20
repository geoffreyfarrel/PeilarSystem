# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
# Run on a connected device or emulator
flutter run

# Run all tests
flutter test

# Run a single test file
flutter test test/features/digital_card_test.dart

# Analyze for lint/type errors
flutter analyze

# Get dependencies
flutter pub get
```

## Coding rules

- **No hardcoded values** — all literals (colours, strings, sizes, URLs) must be extracted to named constants or variables.
- **Functional style preferred** — favour pure functions, immutable data, and stateless widgets where possible.
- **UI inspiration** — Shadcn / HeroUI aesthetics: clean, minimal, well-spaced.
- **String constants** — all user-visible text goes through `appTextProvider` (see i18n section below); never inline raw strings in widgets.

## After every completed task

1. Run `flutter analyze` — fix all warnings before proceeding.
2. Run `flutter test` — all tests must pass.
3. If both pass, commit and push:
   - Commit format: `<type>:<Message>` — e.g. `feat:AddDigitalCardWidget`, `fix:CorrectBindingFlow`, `refactor:CleanupDigitalCard`.
   - Push to the current branch on GitHub.

## Architecture

This is a Flutter superapp — a mock "Peilar x EasyCard" Easy Wallet targeting NTPU students in Sanxia, Taiwan. The app supports two user roles: `guest` and `student` (unlocked after binding a Student ID).

### State management & routing

- **Riverpod** (`flutter_riverpod`) for all state. Every feature exposes providers in `lib/features/<feature>/presentation/providers/`. Use `NotifierProvider`/`AsyncNotifierProvider` for mutable state; `StateProvider` for simple primitives.
- **GoRouter** (`go_router`) with a single `appRouter` defined in [lib/core/routing/app_router.dart](lib/core/routing/app_router.dart). Route access control lives in [lib/core/routing/feature_access.dart](lib/core/routing/feature_access.dart).

### Feature structure

Each feature under `lib/features/<feature>/` follows clean architecture:

```
domain/
  entities/       # Plain Dart classes, no Flutter/framework imports
  repositories/   # Abstract repository interfaces
data/
  repositories/   # Concrete implementations (mock or MySQL)
presentation/
  pages/          # Full-screen ConsumerWidget/ConsumerStatefulWidget
  widgets/        # Reusable sub-widgets
  providers/      # Riverpod providers + Notifier classes
```

Domain entities have zero framework dependencies. This boundary is a hard constraint from the project constitution (TC-002).

### Features & access control

| Feature | User role | Data layer |
|---|---|---|
| Landing / home | All | Mock |
| Digital Card | All (bind flow) | **MySQL** via `mysql1` |
| AI Itinerary | All | Mock |
| Travel Hub | All | Mock |
| QR Payment | All | Mock |
| Laundry Hub | All | Mock |
| Secondhand Books | Student only | Mock |
| Student Forum | Student only | Mock |

`studentAuthProvider` (in `lib/features/auth/`) holds the active `StudentAccount?`. The `isStudentLoggedInProvider` bool is derived from it.

### Digital Card & MySQL

`MySqlDigitalCardRepository` ([lib/features/digital_card/data/repositories/mysql_digital_card_repository.dart](lib/features/digital_card/data/repositories/mysql_digital_card_repository.dart)) connects to `localhost:3306`, database `peilar_db`. The credentials in `digitalCardRepositoryProvider` are dev defaults (`root`, no password). The repository is injected via `digitalCardRepositoryProvider`; override it with a `MockRepository` in tests.

The `user_bindings` table schema (not yet in a migration file) must contain `id`, `user_id`, `student_id`, `bound_at`.

### Internationalisation

All user-visible strings are looked up through `appTextProvider`, a `Map<String, String>` keyed by string IDs. Both `zh` (Traditional Chinese, default) and `en` maps live in [lib/features/landing/presentation/providers/language_provider.dart](lib/features/landing/presentation/providers/language_provider.dart). The language toggle lives in `LanguageToggle` widget and switches `languageProvider`.

### Theme

[lib/core/theme/app_theme.dart](lib/core/theme/app_theme.dart) — Material 3, seed color `#4EA3E7` (blue). Font preference: SF Pro Text / Helvetica Neue / Arial. Hardcoded brand colours used throughout UI: `#515F49` (dark green), `#79926C` (green), `#E52D88` (pink), `#4EA3E7` (blue), `#FFED69` (yellow).

### Specs

Feature specs live under `specs/<branch-name>/`. Key docs: `spec.md` (requirements), `data-model.md`, `tasks.md`, `plan.md`. Active branch specs are in `specs/003-digital-card-refactor/`.

### Current branch goal (003-digital-card-refactor)

Refactor `lib/features/digital_card/` to: remove dead code, persist binding via MySQL, and display a premium digital card design post-binding. Mock validation accepts any Student/Staff ID.
