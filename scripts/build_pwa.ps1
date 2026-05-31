param(
    [string]$Env = "staging"
)

Write-Host "Building Fudi PWA for $Env..." -ForegroundColor Cyan

flutter build web --dart-define=APP_ENV=$Env

if ($LASTEXITCODE -ne 0) {
    Write-Error "Flutter build failed"
    exit 1
}

& "$PSScriptRoot\clean_flutter_sw.ps1"

Write-Host ""
Write-Host "PWA build ready in build\web/" -ForegroundColor Green
Write-Host "Deploy with: cd build\web && vercel --prod" -ForegroundColor Yellow
