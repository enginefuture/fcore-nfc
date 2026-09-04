#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPOSITORY_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
ARCHIVE_PATH="${ARCHIVE_PATH:-$REPOSITORY_ROOT/build/FCoreNFC.xcarchive}"
EXPORT_PATH="${EXPORT_PATH:-$REPOSITORY_ROOT/build/TestFlightUpload}"

: "${DEVELOPMENT_TEAM:?Set DEVELOPMENT_TEAM to the Apple Developer Team ID}"
test -d "$ARCHIVE_PATH"

EXPORT_OPTIONS="$(mktemp /tmp/fcore-export-options.XXXXXX.plist)"
trap 'rm -f "$EXPORT_OPTIONS"' EXIT
cp "$REPOSITORY_ROOT/ios/ExportOptions.plist" "$EXPORT_OPTIONS"
plutil -insert teamID -string "$DEVELOPMENT_TEAM" "$EXPORT_OPTIONS"

AUTHENTICATION_ARGUMENTS=()
if [[ -n "${ASC_KEY_PATH:-}" && -n "${ASC_KEY_ID:-}" && -n "${ASC_ISSUER_ID:-}" ]]; then
  AUTHENTICATION_ARGUMENTS=(
    -authenticationKeyPath "$ASC_KEY_PATH"
    -authenticationKeyID "$ASC_KEY_ID"
    -authenticationKeyIssuerID "$ASC_ISSUER_ID"
  )
fi

xcodebuild -exportArchive \
  -archivePath "$ARCHIVE_PATH" \
  -exportPath "$EXPORT_PATH" \
  -exportOptionsPlist "$EXPORT_OPTIONS" \
  -allowProvisioningUpdates \
  "${AUTHENTICATION_ARGUMENTS[@]}"

echo "Archive submitted to App Store Connect. Check processing status before inviting testers."

