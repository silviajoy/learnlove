# Architecture Overview

This project follows a feature-aware, layered approach (incrementally applied).

Layers implemented:
- Presentation: BLoC-based (`flutter_bloc`) in `lib/blocs` (migrating to `features/*/presentation`).
- Domain: Use-cases placed under `lib/features/*/domain` (example: `SelectWordsUseCase`).
- Data: Hive-backed repository under `lib/data/local` (concrete implementation).

Key decisions:
- Dependency injection via `get_it` (see `lib/core/di/injection.dart`).
- Centralized theming in `lib/core/theme/app_theme.dart`.
- Shared UI widgets under `lib/core/ui/widgets/`.

Next steps to complete fully feature-based split:
- Move feature files into `lib/features/*` directories (presentation/bloc/ui).
- Create mappers between data models and domain entities.
- Add more use-cases and unit tests for domain logic.
