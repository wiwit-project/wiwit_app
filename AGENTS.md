# Repository guidance

## Project

Wiwit is a Flutter mobile client for a self-hosted finance tracker. Users configure their own server at runtime; do not hard-code an API base URL. The Dart SDK constraint is defined in `pubspec.yaml`. Android and iOS platform projects live in `android/` and `ios/`.

## Layout

- `lib/main.dart`: application entry point.
- `lib/views/<feature>/`: screens, feature controllers, and screen-specific `components/`.
- `lib/shared/components/`: reusable widgets.
- `lib/shared/models/wiwit_api/`: API request and response models.
- `lib/shared/providers/`: Riverpod state and dependency providers.
- `lib/shared/services/apis/`: Chopper API services.
- `lib/shared/services/networking/`: interceptors, conversion, and server probing.
- `lib/shared/utils/`: formatting, server URL handling, and other shared helpers.
- `test/`: tests mirroring the source structure, currently focused on model parsing and utilities.
- `assets/` and `fonts/`: bundled assets declared in `pubspec.yaml`.

## Commands

Run commands from the repository root:

```shell
flutter pub get
flutter run
flutter analyze
flutter test
flutter test test/shared/utils/format_utils_test.dart
flutter test --plain-name "parses category items"
dart run build_runner build --delete-conflicting-outputs
flutter build apk --split-per-abi --release
```

Format changed Dart files with `dart format <paths>`. After changing annotated models, providers, or services with generated parts, run `build_runner` and include the relevant generated changes. Chopper outputs use `*.chopper.g.dart`, as configured in `build.yaml`. Edit source files rather than generated `*.g.dart` files.

## Architecture and conventions

- Follow the existing Riverpod, Chopper, and JSON serialization patterns.
- `RootView` selects server setup, login, or home based on server configuration and authentication. Preserve this gating so API calls do not run before a server is configured.
- `chopperClientProvider` watches `serverUrlProvider` and requires a configured server.
- Register new response types in the `JsonSerializableConverter` map in `lib/shared/providers/chopper_provider.dart` so responses deserialize correctly.
- Non-2xx responses are thrown as `ProblemDetails` when parseable, otherwise as `ChopperHttpException`. Follow existing error handling and display appropriate API error details.
- UI money values use integer cents. Keep conversion to and from API decimal strings in `lib/shared/utils/format_utils.dart`.
- Use relative imports within `lib/`; tests use `package:wiwit_app/...` imports. `prefer_relative_imports` is enforced.
- Follow existing Dart dot-shorthand usage where the type is inferred, such as `brightness: .dark` and `fontWeight: .w600`.
- Riverpod lints are configured as an analysis-server plugin in `analysis_options.yaml`.
- Reuse existing UI components, themes, and feature organization when extending screens.

## Validation and scope

- Use Flutter/Dart MCP tools when available for analysis, formatting, tests, running the app, and runtime inspection. Fall back to the Flutter/Dart CLI when the needed MCP capability is unavailable.
- After making app code changes, hot reload the running Flutter app through the Flutter/Dart MCP, and check for runtime errors. If no app is running, can ignore, I will lanch the app myself.
- Preserve unrelated working-tree changes; keep edits focused on the requested task. But if find unrelated issues, can report them in the final response.
- Run `flutter analyze` and relevant tests for code changes. Add focused coverage for changed parsing, calculations, or other meaningful logic when appropriate.
- In the final response, describe the change, validation performed, and any remaining limitations.
- Don't ever stage (as in git stage) the changes yourself.
