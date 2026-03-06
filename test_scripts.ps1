# Test script for VSCodium build scripts
# PowerShell version for Windows

Write-Host "=== Testing VSCodium Build Scripts ===" -ForegroundColor Cyan
Write-Host ""

$ErrorCount = 0

# Test 1: Check if required files exist
Write-Host "Test 1: Checking required files..." -ForegroundColor Yellow
$requiredFiles = @(
    "build.sh",
    "utils.sh",
    "version.sh",
    "prepare_vscode.sh",
    "get_repo.sh",
    "check_tags.sh",
    "product.json"
)

foreach ($file in $requiredFiles) {
    if (Test-Path $file) {
        Write-Host "✓ $file exists" -ForegroundColor Green
    } else {
        Write-Host "✗ $file missing" -ForegroundColor Red
        $ErrorCount++
    }
}
Write-Host ""

# Test 2: Check line endings
Write-Host "Test 2: Checking line endings..." -ForegroundColor Yellow
$bashFiles = @("build.sh", "utils.sh", "version.sh", "prepare_vscode.sh", "get_repo.sh", "check_tags.sh")

foreach ($file in $bashFiles) {
    $content = Get-Content -Path $file -Raw
    if ($content -match "`r`n") {
        Write-Host "⚠ $file has Windows line endings (CRLF)" -ForegroundColor Yellow
    } else {
        Write-Host "✓ $file has Unix line endings (LF)" -ForegroundColor Green
    }
}
Write-Host ""

# Test 3: Check JSON syntax
Write-Host "Test 3: Checking JSON syntax..." -ForegroundColor Yellow
$json = $null
try {
    $json = Get-Content "product.json" -Raw | ConvertFrom-Json
    Write-Host "✓ product.json is valid JSON" -ForegroundColor Green
} catch {
    Write-Host "✗ product.json has JSON errors" -ForegroundColor Red
    $ErrorCount++
}
Write-Host ""

# Test 4: Check product.json structure
Write-Host "Test 4: Validating product.json structure..." -ForegroundColor Yellow
if ($json) {
    $requiredKeys = @(
        "extensionAllowedBadgeProviders",
        "extensionEnabledApiProposals",
        "extensionKind",
        "extensionPointExtensionKind",
        "extensionSyncedKeys",
        "extensionVirtualWorkspacesSupport"
    )

    foreach ($key in $requiredKeys) {
        if ($json.PSObject.Properties.Name -contains $key) {
            Write-Host "✓ product.json has '$key'" -ForegroundColor Green
        } else {
            Write-Host "✗ product.json missing '$key'" -ForegroundColor Red
            $ErrorCount++
        }
    }
}
Write-Host ""

# Test 5: Check file sizes
Write-Host "Test 5: Checking file sizes..." -ForegroundColor Yellow
foreach ($file in $requiredFiles) {
    $size = (Get-Item $file).Length
    if ($size -gt 0) {
        Write-Host "✓ $file size: $size bytes" -ForegroundColor Green
    } else {
        Write-Host "✗ $file is empty" -ForegroundColor Red
        $ErrorCount++
    }
}
Write-Host ""

# Test 6: Check bash script structure
Write-Host "Test 6: Checking bash script structure..." -ForegroundColor Yellow
foreach ($file in $bashFiles) {
    $content = Get-Content -Path $file -Raw
    
    if ($content -match "^#!/") {
        Write-Host "✓ $file has shebang" -ForegroundColor Green
    } else {
        Write-Host "⚠ $file missing shebang" -ForegroundColor Yellow
    }
    
    if ($content -match "set -e") {
        Write-Host "✓ $file has error handling" -ForegroundColor Green
    } else {
        Write-Host "⚠ $file missing error handling" -ForegroundColor Yellow
    }
}
Write-Host ""

# Test 7: Check for key functions
Write-Host "Test 7: Checking for key functions..." -ForegroundColor Yellow
$utilsContent = Get-Content "utils.sh" -Raw
$functions = @("apply_patch", "exists", "is_gnu_sed", "replace")
foreach ($func in $functions) {
    if ($utilsContent -match "$func\(\)") {
        Write-Host "✓ utils.sh contains: $func" -ForegroundColor Green
    } else {
        Write-Host "✗ utils.sh missing: $func" -ForegroundColor Red
        $ErrorCount++
    }
}
Write-Host ""

# Test 8: Check environment variables
Write-Host "Test 8: Checking environment variable usage..." -ForegroundColor Yellow
$envVars = @("APP_NAME", "VSCODE_QUALITY", "OS_NAME", "RELEASE_VERSION", "MS_COMMIT")
$allContent = ""
foreach ($file in $bashFiles) {
    $allContent += Get-Content $file -Raw
}

foreach ($var in $envVars) {
    if ($allContent -match "\$\{?$var\}?") {
        Write-Host "✓ Found: $var" -ForegroundColor Green
    }
}
Write-Host ""

# Summary
Write-Host "=== Test Summary ===" -ForegroundColor Cyan
if ($ErrorCount -eq 0) {
    Write-Host "All critical tests passed! ✓" -ForegroundColor Green
    exit 0
} else {
    Write-Host "Found $ErrorCount error(s) ✗" -ForegroundColor Red
    exit 1
}
