# Railway + APK + Google Login (Production Checklist)

## 1) Deploy backend to Railway

1. Create a new Railway project from this repo and set service root to `backend/`.
2. Add a PostgreSQL service in the same Railway project.
3. Set backend variables in Railway:
   - `SECRET_KEY=<strong-secret>`
   - `DEBUG=False`
   - `USE_SQLITE=False`
   - `DATABASE_URL=${{Postgres.DATABASE_URL}}`
   - `ALLOWED_HOSTS=<your-backend-domain>`
   - `CORS_ALLOWED_ORIGINS=https://<your-frontend-domain>`
   - `CSRF_TRUSTED_ORIGINS=https://<your-frontend-domain>`
   - `CORS_ALLOW_LOCALHOST_ANY_PORT=False`
   - `GOOGLE_WEB_CLIENT_ID=<google-web-client-id>`
   - `GOOGLE_OAUTH_CLIENT_IDS=<web-client-id>,<android-client-id>`
4. Deploy and verify:
   - `https://<your-backend-domain>/api/health`
   - `https://<your-backend-domain>/api/docs/`

## 2) Prepare Android release signing

1. Generate release keystore (once):

```powershell
keytool -genkey -v -keystore mobile\android\keystore\tutta-release.jks -keyalg RSA -keysize 2048 -validity 10000 -alias tutta_release
```

Or use the prepared helper:

```powershell
powershell -ExecutionPolicy Bypass -File mobile\android\scripts\create_release_keystore.ps1
```

2. Create `mobile/android/key.properties` from `mobile/android/key.properties.example`.
3. Fill real values:
   - `storePassword`
   - `keyPassword`
   - `keyAlias`
   - `storeFile`

## 3) Configure Google Sign-In for release APK

1. Use final package id: `uz.tutta.app` (or set `TUTTA_APPLICATION_ID` in `mobile/android/local.properties`).
2. Get SHA-1 and SHA-256 from your release keystore:

```powershell
keytool -list -v -keystore mobile\android\keystore\tutta-release.jks -alias tutta_release
```

3. In Google Cloud / Firebase:
   - create Android OAuth client for package `uz.tutta.app` + release SHA fingerprints;
   - create Web OAuth client (for backend token validation).
4. Download `google-services.json` for Android app and place it at:
   - `mobile/android/app/google-services.json`
5. Keep backend `GOOGLE_OAUTH_CLIENT_IDS` containing at least:
   - web client id
   - android client id

## 4) Build APK that points to Railway

From repo root:

```powershell
D:\dart-flutt\flutter\bin\flutter.bat pub get
D:\dart-flutt\flutter\bin\flutter.bat build apk --release --dart-define=API_BASE_URL=https://<your-backend-domain>/api --dart-define=GOOGLE_SERVER_CLIENT_ID=<google-web-client-id> --dart-define=GOOGLE_WEB_CLIENT_ID=<google-web-client-id>
```

APK output:

- `mobile/build/app/outputs/flutter-apk/app-release.apk`

## 5) Mandatory smoke test before sharing APK

1. Open app, register/login with email.
2. Login with Google account (new and existing user).
3. Open listing details with map.
4. Create booking request.
5. Verify backend logs on Railway for `/api/auth/google` status 200.
