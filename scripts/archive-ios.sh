#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPOSITORY_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
ARCHIVE_PATH="${ARCHIVE_PATH:-$REPOSITORY_ROOT/build/FCoreNFC.xcarchive}"
BUNDLE_IDENTIFIER="${BUNDLE_IDENTIFIER:-app.enginefuture.fcorenfc}"

: "${DEVELOPMENT_TEAM:?Set DEVELOPMENT_TEAM to the Apple Developer Team ID}"

mkdir -p "$(dirname "$ARCHIVE_PATH")"

xcodebuild archive \
  -project "$REPOSITORY_ROOT/ios/FCoreNFC.xcodeproj" \
  -scheme FCoreNFC \
  -configuration Release \
  -destination "generic/platform=iOS" \
  -archivePath "$ARCHIVE_PATH" \
  -allowProvisioningUpdates \
  DEVELOPMENT_TEAM="$DEVELOPMENT_TEAM" \
  PRODUCT_BUNDLE_IDENTIFIER="$BUNDLE_IDENTIFIER"

echo "Archive created at $ARCHIVE_PATH"

