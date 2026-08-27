#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 ]]; then
    echo "usage: $0 /path/to/th08-modern.app" >&2
    exit 2
fi

bundle="$1"
executable="${bundle}/Contents/MacOS/th08-modern"
plist="${bundle}/Contents/Info.plist"

if [[ "$(uname -s)" != "Darwin" ]]; then
    echo "Bundle verification requires macOS." >&2
    exit 1
fi
if [[ ! -x "${executable}" || ! -f "${plist}" ]]; then
    echo "Incomplete macOS application bundle: ${bundle}" >&2
    exit 1
fi

lipo -verify_arch arm64 "${executable}"
bundle_id="$(plutil -extract CFBundleIdentifier raw -o - "${plist}")"
if [[ "${bundle_id}" != "org.th08-research.th08-modern" ]]; then
    echo "Unexpected bundle identifier: ${bundle_id}" >&2
    exit 1
fi

if otool -L "${executable}" | grep -Eq '/(Cellar|opt/homebrew)/'; then
    echo "The bundle still links Homebrew libraries and is a development artifact." >&2
else
    echo "No direct Homebrew library references were found."
fi

echo "Verified arm64 bundle: ${bundle}"
