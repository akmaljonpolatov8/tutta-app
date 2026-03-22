# Release Readiness Checklist

This checklist tracks the final pre-release steps.

## 1) Smoke in Real API Mode

Status: in-progress

What was validated now:
- Real-API app startup on Chrome with all fake flags disabled (successful launch).
- Android emulator detected and launched successfully.
- Android SDK licenses are accepted (`flutter doctor -v` shows Android toolchain green).
- Android real-API debug launch on emulator succeeded (`flutter run -d emulator-5554 ...`).
- Build now tolerates missing `google-services.json` for non-FCM smoke runs.

Current environment blocker:
- Backend host `api.tutta.uz` is not resolvable in this network environment (DNS failure in scripted endpoint checks).

Command used:
```bash
flutter run -d chrome \
  --dart-define=USE_FAKE_AUTH=false \
  --dart-define=USE_FAKE_BOOKINGS=false \
  --dart-define=USE_FAKE_PAYMENTS=false \
  --dart-define=USE_FAKE_REVIEWS=false \
  --dart-define=USE_FAKE_CHAT=false \
  --dart-define=USE_FAKE_NOTIFICATIONS=false \
  --dart-define=USE_FAKE_HOST_LISTING=false \
  --dart-define=USE_FAKE_PROFILE_VERIFICATION=false
```

Still required to mark done:
- Auth login/logout smoke
- Bookings open/list smoke
- Notifications list/open smoke
- Role switch smoke
- Backend DNS/network access to `api.tutta.uz` from the test environment.

## 2) Firebase/FCM on Real Device

Status: blocked for full FCM validation (Firebase native config files are missing)

Blocking details:
- Missing Android file: `android/app/google-services.json`
- Missing iOS file: `ios/Runner/GoogleService-Info.plist`

Required completion steps:
1. Download Firebase config files for this app from Firebase Console.
2. Place files at the exact paths above.
3. Connect physical Android/iOS device.
4. Run app with same real-API flags.
5. Grant notification permission.
6. Confirm token retrieval and backend registration from Settings diagnostics.
7. Send test push from Firebase Console and verify foreground + open-app handling.

Quick device check command:
```bash
flutter devices
```

## 3) Green CI on PR/Release Branch

Status: blocked-until-push

Notes:
- CI workflow exists in `.github/workflows/flutter-ci.yml`.
- This step can only be completed after pushing branch and opening PR (or push to release branch).

Completion criterion:
- GitHub Actions checks for format/analyze/test are all green.

## 4) Final UAT for Critical Renter/Host Flows

Status: pending

Critical flows to verify:
- Renter: auth -> role select -> home tabs -> search -> bookings -> notifications -> sign out
- Host: role switch -> dashboard -> listings -> bookings/requests -> profile -> sign out
- Error resilience: sign-out failure messaging and interaction lock/unlock behavior

Completion criterion:
- No blocker defects in the above flows.
- Any minor issues documented and triaged.
