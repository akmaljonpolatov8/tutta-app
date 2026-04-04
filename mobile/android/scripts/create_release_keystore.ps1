param(
    [string]$Alias = "tutta_release",
    [string]$StorePath = "..\keystore\tutta-release.jks",
    [string]$ValidityDays = "10000"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Resolve-Keytool {
    $candidates = @(
        "$env:JAVA_HOME\bin\keytool.exe",
        "C:\Program Files\Android\Android Studio\jbr\bin\keytool.exe",
        "C:\Users\$env:USERNAME\AppData\Local\Programs\Android Studio\jbr\bin\keytool.exe"
    ) | Where-Object { $_ -and (Test-Path $_) }

    $candidateList = @($candidates)
    if ($candidateList.Length -gt 0) {
        return $candidateList[0]
    }

    $keytoolCmd = Get-Command keytool.exe -ErrorAction SilentlyContinue
    $fromPath = $null
    if ($keytoolCmd) {
        $fromPath = $keytoolCmd.Source
    }
    if ($fromPath) {
        return $fromPath
    }

    $javaCmd = Get-Command java.exe -ErrorAction SilentlyContinue
    $javaFromPath = $null
    if ($javaCmd) {
        $javaFromPath = $javaCmd.Source
    }
    if ($javaFromPath) {
        $javaDir = Split-Path -Parent $javaFromPath
        $adjacent = Join-Path $javaDir "keytool.exe"
        if (Test-Path $adjacent) {
            return $adjacent
        }
    }

    throw "keytool.exe not found. Install JDK 17+ and set JAVA_HOME, then rerun."
}

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$androidDir = Split-Path -Parent $scriptDir
$storeFullPath = Resolve-Path (Join-Path $androidDir $StorePath) -ErrorAction SilentlyContinue
if (-not $storeFullPath) {
    $storeFullPath = Join-Path $androidDir $StorePath
}

$storeDir = Split-Path -Parent $storeFullPath
if (-not (Test-Path $storeDir)) {
    New-Item -ItemType Directory -Path $storeDir | Out-Null
}

$storePassword = Read-Host "Enter keystore password"
$keyPassword = Read-Host "Enter key password (can be same)"
$dname = Read-Host "Enter certificate name (example: CN=Tutta, OU=Mobile, O=Tutta, L=Tashkent, ST=Tashkent, C=UZ)"

$keytool = Resolve-Keytool

& $keytool `
  -genkeypair `
  -v `
  -keystore $storeFullPath `
  -alias $Alias `
  -keyalg RSA `
  -keysize 2048 `
  -validity $ValidityDays `
  -storepass $storePassword `
  -keypass $keyPassword `
  -dname $dname

$keyPropsPath = Join-Path $androidDir "key.properties"
@(
    "storePassword=$storePassword"
    "keyPassword=$keyPassword"
    "keyAlias=$Alias"
    "storeFile=$StorePath"
) | Set-Content -Path $keyPropsPath -Encoding UTF8

Write-Host ""
Write-Host "Keystore created: $storeFullPath"
Write-Host "key.properties created: $keyPropsPath"
Write-Host ""
Write-Host "SHA fingerprints:"
& $keytool -list -v -keystore $storeFullPath -alias $Alias -storepass $storePassword
