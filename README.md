# Tutta

Flutter application for renter/host flows with role-based home shell, auth,
notifications, bookings, and premium features.

## Requirements

- Flutter stable
- Dart stable (bundled with Flutter)

## Local Setup

```bash
flutter pub get
flutter analyze
flutter test
```

## Runtime Data Source Switches

By default, the app runs with fake repositories for local development.
Use `--dart-define` flags to switch to backend APIs.

Available flags:

- `USE_FAKE_AUTH` (default: `true`)
- `USE_FAKE_BOOKINGS` (default: `true`)
- `USE_FAKE_PAYMENTS` (default: `true`)
- `USE_FAKE_REVIEWS` (default: `true`)

Example (use backend for auth and bookings):

```bash
flutter run \
	--dart-define=USE_FAKE_AUTH=false \
	--dart-define=USE_FAKE_BOOKINGS=false
```

## CI Quality Gates

GitHub Actions workflow: `.github/workflows/flutter-ci.yml`

Checks run on push/PR:

- `dart format --set-exit-if-changed lib test`
- `flutter analyze`
- `flutter test`

## Release Readiness Checklist

1. Run full quality gates locally: `flutter analyze && flutter test`.
2. Validate real API mode in smoke scenarios:
	 - Auth sign in/out
	 - Home shell role switch
	 - Bookings flow
	 - Notifications token sync and retry
3. Verify Firebase/FCM behavior on at least one real target device.
4. Ensure CI is green for the release branch/PR.
5. Run UAT pass for critical renter + host journeys.
