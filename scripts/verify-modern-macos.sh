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

lipo "${executable}" -verify_arch arm64
bundle_id="$(plutil -extract CFBundleIdentifier raw -o - "${plist}")"
if [[ "${bundle_id}" != "org.th08-research.th08-modern" ]]; then
    echo "Unexpected bundle identifier: ${bundle_id}" >&2
    exit 1
fi

while IFS= read -r candidate; do
    if file "${candidate}" | grep -q 'Mach-O'; then
        if otool -L "${candidate}" | grep -Eq '/(Cellar|opt/homebrew)/'; then
            echo "Bundle item still links a Homebrew path: ${candidate}" >&2
            exit 1
        fi
        lipo "${candidate}" -verify_arch arm64
    fi
done < <(find "${bundle}/Contents" -type f -print)

echo "Verified arm64 bundle: ${bundle}"
