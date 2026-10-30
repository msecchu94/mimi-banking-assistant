# Mimi — Flutter client

iOS + Android client for the Mimi backend.

## Environments

The environment is selected at build time and is required:

```sh
flutter run --dart-define-from-file=config/development.json
flutter build ipa --dart-define-from-file=config/production.json
```

Each config file sets `APP_ENV` and `API_BASE_URL` (the backend base URL).
Both are required: the app refuses to start without them. Production has no
deployed backend yet, so its `API_BASE_URL` is intentionally empty and a
production build fails at startup until a real URL is set.

To add an environment (e.g. staging), add a value to `AppEnvironment` and a
matching `config/<env>.json`.

## Code generation

Riverpod, AutoRoute, Freezed and json_serializable use `build_runner`.
Generated files (`*.g.dart`, `*.gr.dart`, `*.freezed.dart`) are never edited
by hand:

```sh
dart run build_runner build
```

## Checks

```sh
dart format lib test integration_test
flutter analyze
flutter test
flutter test integration_test --dart-define-from-file=config/development.json
```

## Structure

`lib/` is feature-first Clean Architecture:

- `app/` — app shell, routing, composition.
- `core/` — cross-cutting technical foundations (config, errors).
- `shared/` — code reused by several features.
- `features/<feature>/{domain,data,presentation}/`.

Domain is pure Dart (no Flutter, Riverpod or transport imports). Use cases
own application logic and return `Either<Failure, T>`; Riverpod notifiers only
adapt use-case results to view state. Folders are created when first needed.
