$buildDir = "build\web"
$bootstrapPath = Join-Path $buildDir "flutter_bootstrap.js"

if (Test-Path $bootstrapPath) {
    $content = Get-Content $bootstrapPath -Raw

    $content = $content -replace 'serviceWorkerSettings:\s*\{\s*serviceWorkerVersion:\s*"[^"]*"\s*/\*[^*]*\*/\s*\},?', ''

    Set-Content $bootstrapPath $content -NoNewline

    $swPath = Join-Path $buildDir "flutter_service_worker.js"
    if (Test-Path $swPath) {
        Remove-Item $swPath
    }

    Write-Host "Flutter SW removed. Custom PWA SW is the only active worker."
} else {
    Write-Error "flutter_bootstrap.js not found in $buildDir"
}
