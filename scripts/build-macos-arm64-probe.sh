#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd "$(dirname "$0")/.." && pwd)"
build_dir="${TH08_MACOS_ARM64_PROBE_DIR:-${repo_dir}/build/macos-arm64-probe}"

cmake_args=(
    -S "${repo_dir}"
    -B "${build_dir}"
    -G Ninja
    -DTH08_ARM64_COMPILE_PROBE=ON
)

case "$(uname -s)" in
    Darwin)
        if [[ "$(uname -m)" != "arm64" ]]; then
            echo "The native macOS source gate requires an Apple Silicon runner." >&2
            exit 1
        fi
        cmake_args+=( -DCMAKE_OSX_ARCHITECTURES=arm64 )
        ;;
    Linux)
        cmake_args+=(
            -DCMAKE_TOOLCHAIN_FILE="${repo_dir}/cmake/aarch64-compile-probe-toolchain.cmake"
        )
        ;;
    *)
        echo "Unsupported source-gate host: $(uname -s)" >&2
        exit 1
        ;;
esac

cmake "${cmake_args[@]}"
cmake --build "${build_dir}" --parallel "${TH08_MACOS_BUILD_JOBS:-1}"

probe_object="${build_dir}/CMakeFiles/th08-arm64-authored-compile.dir/src/main.cpp.o"
if [[ ! -f "${probe_object}" ]]; then
    echo "ARM64 source-gate object was not produced: ${probe_object}" >&2
    exit 1
fi

if [[ "$(uname -s)" == "Darwin" ]]; then
    lipo -verify_arch arm64 "${probe_object}"
else
    file "${probe_object}" | grep -q 'ARM aarch64'
fi

echo "ARM64 authored-source compile gate passed: ${probe_object}"
