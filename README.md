# Echo Memory

Echo Memory is a private, offline memory game built with Flutter. Players watch
visual patterns, recall them in order, and build streaks across seven focused
game modes.

## Release profile

- Flutter 3.44.6 / Dart 3.12.2
- Android package: `com.dolfinmind.echomemory`
- Android target SDK 36, minimum SDK 24
- No account, backend, ads, analytics, or internet permission
- Scores and settings stay in local device storage

## Run locally

```bash
flutter pub get
flutter run
```

The project also pins Flutter 3.44.6 in `.fvmrc` for teams using FVM.

## Verify

```bash
flutter analyze
flutter test
```

## Create the Play bundle

Create and securely back up a Play upload key before the production build:

```bash
keytool -genkeypair -v \
  -keystore android/app/upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 -alias upload
cp android/app/key.properties.example android/app/key.properties
```

Replace the placeholders in `android/app/key.properties`, then build:

```bash
flutter build appbundle --release
```

The result is written to
`build/app/outputs/bundle/release/app-release.aab`.

If `key.properties` is absent, the current Gradle configuration uses the local
debug key only so release-mode behavior can be verified. Never upload that
fallback bundle to Play. The upload keystore and its passwords must not be
committed.

## Play Store handoff

Descriptions, policy answers, screenshots, icon, feature graphic, and the
release checklist are in [`store_listing`](store_listing/).
