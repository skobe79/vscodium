#!/usr/bin/env bash

echo "=== VSCodium Build System Demo ==="
echo ""

# Source utilities
source utils.sh

echo "1. Environment Variables:"
echo "   APP_NAME: ${APP_NAME:-VSCodium}"
echo "   BINARY_NAME: ${BINARY_NAME:-codium}"
echo "   ORG_NAME: ${ORG_NAME:-VSCodium}"
echo ""

echo "2. Testing utility functions:"
echo -n "   exists(bash): "
if exists bash; then echo "✓"; else echo "✗"; fi
echo -n "   exists(nonexistent): "
if exists nonexistent; then echo "✓"; else echo "✗"; fi
echo ""

echo "3. Version calculation:"
export RELEASE_VERSION=1.95.0
source version.sh
echo "   RELEASE_VERSION: $RELEASE_VERSION"
echo "   BUILD_SOURCEVERSION: $BUILD_SOURCEVERSION"
echo ""

echo "4. Product configuration:"
if [ -f product.json ]; then
    echo "   product.json exists ($(wc -c < product.json) bytes)"
    echo "   Contains extension configurations for VSCodium"
fi
echo ""

echo "5. Build scripts available:"
for script in build.sh prepare_vscode.sh get_repo.sh check_tags.sh; do
    if [ -f "$script" ]; then
        lines=$(wc -l < "$script")
        echo "   ✓ $script ($lines lines)"
    fi
done
echo ""

echo "=== Demo Complete ==="
