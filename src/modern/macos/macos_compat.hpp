#pragma once

#ifndef TH08_MODERN_MACOS
#error "This header is only for the modern macOS build."
#endif

// Reuse the Win32-shaped declarations shared by the Linux and Web ports while
// the native macOS runtime boundary is brought up.  The public game sources
// only depend on this declaration surface, not on Linux kernel behavior.
#include <stdlib.h>
#include "modern/linux/linux_compat.hpp"

// The reconstruction assertions describe the original VC7 x86 object layout.
// ARM64 deliberately uses native pointers while the remaining raw-size clears
// and offset-shaped accesses are converted to symbolic members.  Serialization
// structures receive separate platform-independent checks as that work lands.
#if defined(TH08_MODERN_64BIT)
#undef C_ASSERT
#define C_ASSERT(expression)
#endif
