param(
    [string]$Device = "emulator-5554",
    [switch]$NoRun,
    [switch]$SkipChecks
)

$ErrorActionPreference = "Stop"

function Write-Stage($Message) {
    Write-Host "`n==> $Message" -ForegroundColor Cyan
}

$realApiDefines = @(
    "--dart-define=USE_FAKE_AUTH=false",
    "--dart-define=USE_FAKE_BOOKINGS=false",
    "--dart-define=USE_FAKE_PAYMENTS=false",
    "--dart-define=USE_FAKE_REVIEWS=false",
    "--dart-define=USE_FAKE_CHAT=false",
    "--dart-define=USE_FAKE_NOTIFICATIONS=false",
    "--dart-define=USE_FAKE_HOST_LISTING=false",
    "--dart-define=USE_FAKE_PROFILE_VERIFICATION=false"
)

if (-not $SkipChecks) {
    Write-Stage "Running static checks"
    flutter analyze
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

    flutter test
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
}

if ($NoRun) {
    Write-Host "NoRun set. Real API command preview:" -ForegroundColor Yellow
    Write-Host "flutter run -d $Device $($realApiDefines -join ' ')" -ForegroundColor Yellow
    exit 0
}

Write-Stage "Launching app in real API mode on '$Device'"
flutter run -d $Device @realApiDefines
exit $LASTEXITCODE
