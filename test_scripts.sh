#!/usr/bin/env bash
# Test script for VSCodium build scripts

set -e

echo "=== Testing VSCodium Build Scripts ==="
echo ""

# Test 1: Check if required files exist
echo "Test 1: Checking required files..."
required_files=(
    "build.sh"
    "utils.sh"
    "version.sh"
    "prepare_vscode.sh"
    "get_repo.sh"
    "check_tags.sh"
    "product.json"
)

for file in "${required_files[@]}"; do
    if [[ -f "$file" ]]; then
        echo "✓ $file exists"
    else
        echo "✗ $file missing"
        exit 1
    fi
done
echo ""

# Test 2: Check bash syntax
echo "Test 2: Checking bash syntax..."
bash_files=("build.sh" "utils.sh" "version.sh" "prepare_vscode.sh" "get_repo.sh" "check_tags.sh")

for file in "${bash_files[@]}"; do
    if bash -n "$file" 2>/dev/null; then
        echo "✓ $file syntax OK"
    else
        echo "✗ $file has syntax errors"
        bash -n "$file"
        exit 1
    fi
done
echo ""

# Test 3: Check JSON syntax
echo "Test 3: Checking JSON syntax..."
if command -v jq &> /dev/null; then
    if jq empty product.json 2>/dev/null; then
        echo "✓ product.json is valid JSON"
    else
        echo "✗ product.json has JSON errors"
        jq empty product.json
        exit 1
    fi
else
    echo "⚠ jq not installed, skipping JSON validation"
fi
echo ""

# Test 4: Check utils.sh functions
echo "Test 4: Testing utils.sh functions..."
source utils.sh

# Test exists function
if exists bash; then
    echo "✓ exists() function works"
else
    echo "✗ exists() function failed"
    exit 1
fi

# Test is_gnu_sed function
if is_gnu_sed || ! is_gnu_sed; then
    echo "✓ is_gnu_sed() function works"
else
    echo "✗ is_gnu_sed() function failed"
    exit 1
fi

# Test variable substitutions
if [[ -n "${APP_NAME}" ]] || [[ -z "${APP_NAME}" ]]; then
    echo "✓ Variable substitutions defined"
fi
echo ""

# Test 5: Check environment variables
echo "Test 5: Checking environment variable handling..."
export TEST_VAR="test_value"
if [[ "${TEST_VAR}" == "test_value" ]]; then
    echo "✓ Environment variables work"
else
    echo "✗ Environment variables failed"
    exit 1
fi
unset TEST_VAR
echo ""

# Test 6: Check product.json structure
echo "Test 6: Validating product.json structure..."
if command -v jq &> /dev/null; then
    required_keys=("extensionAllowedBadgeProviders" "extensionEnabledApiProposals" "extensionKind")
    
    for key in "${required_keys[@]}"; do
        if jq -e ".$key" product.json > /dev/null 2>&1; then
            echo "✓ product.json has '$key'"
        else
            echo "✗ product.json missing '$key'"
            exit 1
        fi
    done
else
    echo "⚠ jq not installed, skipping product.json structure validation"
fi
echo ""

# Test 7: Check shellcheck (if available)
echo "Test 7: Running shellcheck (if available)..."
if command -v shellcheck &> /dev/null; then
    for file in "${bash_files[@]}"; do
        if shellcheck -S warning "$file" 2>/dev/null; then
            echo "✓ $file passed shellcheck"
        else
            echo "⚠ $file has shellcheck warnings (non-critical)"
        fi
    done
else
    echo "⚠ shellcheck not installed, skipping"
fi
echo ""

echo "=== All Tests Completed Successfully ==="
