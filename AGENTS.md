# Repository guidance

- Flutter app; `pubspec.yaml` requires Dart SDK `^3.14.0`. Run `flutter pub get`, `flutter analyze`, and `flutter test` from the repository root. Run one test file with `flutter test test/widget_test.dart`.
- `lib/main.dart` contains the entire current app: `MiTienditaApp` hosts `AppShell`, whose selected index switches between the home preview and placeholder screens. Navigation uses a bottom bar below 600 logical pixels, a rail at 600+, and an extended rail at 1024+.
- Home data is hard-coded preview content. Although networking, routing, state management, and SQLite packages are declared in `pubspec.yaml`, the current app does not wire them up.
- `test/widget_test.dart` is a stale counter template: it references `MyApp`, which the current app does not define. Expect analysis/test failures until the test is updated to match `MiTienditaApp`.
- `analysis_options.yaml` enables `flutter_lints` and excludes build output and all platform directories from analysis.
