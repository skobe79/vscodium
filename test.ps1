Write-Host "=== VSCodium Build Scripts Test ===" -ForegroundColor Cyan
Write-Host ""

$errors = 0

Write-Host "Test 1: File Existence" -ForegroundColor Yellow
$files = @("build.sh", "utils.sh", "version.sh", "prepare_vscode.sh", "get_repo.sh", "check_tags.sh", "product.json")
foreach ($f in $files) {
    if (Test-Path $f) { Write-Host "  OK: $f" -ForegroundColor Green }
    else { Write-Host "  FAIL: $f missing" -ForegroundColor Red; $errors++ }
}

Write-Host "`nTest 2: Line Endings" -ForegroundColor Yellow
$scripts = @("build.sh", "utils.sh", "version.sh", "prepare_vscode.sh", "get_repo.sh", "check_tags.sh")
foreach ($s in $scripts) {
    $c = Get-Content $s -Raw
    if ($c -match "`r`n") { Write-Host "  WARN: $s has CRLF" -ForegroundColor Yellow }
    else { Write-Host "  OK: $s has LF" -ForegroundColor Green }
}

Write-Host "`nTest 3: JSON Validation" -ForegroundColor Yellow
$jsonValid = $false
try {
    $j = Get-Content "product.json" -Raw | ConvertFrom-Json
    $jsonValid = $true
    Write-Host "  OK: product.json valid" -ForegroundColor Green
}
catch {
    Write-Host "  FAIL: product.json invalid" -ForegroundColor Red
    $errors++
}

Write-Host "`nTest 4: JSON Structure" -ForegroundColor Yellow
if ($jsonValid) {
    $keys = @("extensionAllowedBadgeProviders", "extensionEnabledApiProposals", "extensionKind")
    foreach ($k in $keys) {
        if ($j.PSObject.Properties.Name -contains $k) { Write-Host "  OK: $k exists" -ForegroundColor Green }
        else { Write-Host "  FAIL: $k missing" -ForegroundColor Red; $errors++ }
    }
}

Write-Host "`nTest 5: File Sizes" -ForegroundColor Yellow
foreach ($f in $files) {
    $size = (Get-Item $f).Length
    if ($size -gt 0) { Write-Host "  OK: $f ($size bytes)" -ForegroundColor Green }
    else { Write-Host "  FAIL: $f empty" -ForegroundColor Red; $errors++ }
}

Write-Host "`nTest 6: Script Structure" -ForegroundColor Yellow
foreach ($s in $scripts) {
    $c = Get-Content $s -Raw
    if ($c -match "^#!/") { Write-Host "  OK: $s has shebang" -ForegroundColor Green }
    else { Write-Host "  WARN: $s no shebang" -ForegroundColor Yellow }
}

Write-Host "`nTest 7: Utils Functions" -ForegroundColor Yellow
$utils = Get-Content "utils.sh" -Raw
$funcs = @("apply_patch", "exists", "is_gnu_sed", "replace")
foreach ($fn in $funcs) {
    if ($utils -match "$fn\(\)") { Write-Host "  OK: $fn found" -ForegroundColor Green }
    else { Write-Host "  FAIL: $fn missing" -ForegroundColor Red; $errors++ }
}

Write-Host "`n=== Summary ===" -ForegroundColor Cyan
if ($errors -eq 0) {
    Write-Host "All tests passed!" -ForegroundColor Green
    exit 0
}
else {
    Write-Host "$errors error(s) found" -ForegroundColor Red
    exit 1
}
