param(
    [string]$BaseUrl = "https://api.tutta.uz/v1",
    [int]$TimeoutSec = 20
)

$ErrorActionPreference = "Stop"

$paths = @(
    "/auth/otp/request",
    "/bookings",
    "/payments/intents",
    "/notifications/test-user",
    "/chat/threads/test-user"
)

function Test-Endpoint($Url, $Path) {
    try {
        $response = Invoke-WebRequest -Uri $Url -Method Get -TimeoutSec $TimeoutSec -UseBasicParsing
        return [PSCustomObject]@{
            Path = $Path
            StatusCode = [int]$response.StatusCode
            Reachable = $true
            Error = ""
        }
    } catch {
        if ($_.Exception.Response -and $_.Exception.Response.StatusCode) {
            $code = [int]$_.Exception.Response.StatusCode
            return [PSCustomObject]@{
                Path = $Path
                StatusCode = $code
                Reachable = ($code -ge 200 -and $code -lt 500)
                Error = ""
            }
        }

        return [PSCustomObject]@{
            Path = $Path
            StatusCode = -1
            Reachable = $false
            Error = $_.Exception.Message
        }
    }
}

Write-Host "Checking backend reachability: $BaseUrl" -ForegroundColor Cyan

$results = foreach ($path in $paths) {
    $url = "$BaseUrl$path"
    Test-Endpoint -Url $url -Path $path
}

$results | Format-Table -AutoSize | Out-String | Write-Host

$failed = $results | Where-Object { -not $_.Reachable }
if ($failed.Count -gt 0) {
    Write-Host "\nEndpoint errors:" -ForegroundColor Yellow
    $failed | Select-Object Path, Error | Format-Table -AutoSize | Out-String | Write-Host
}

if ($results.Reachable -contains $false) {
    Write-Error "One or more endpoints are not reachable."
    exit 1
}

Write-Host "All checked endpoints responded (2xx-4xx)." -ForegroundColor Green
