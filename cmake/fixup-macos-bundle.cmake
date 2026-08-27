if(NOT APPLE)
    message(FATAL_ERROR "The macOS bundle fixup script must run on macOS.")
endif()
if(NOT DEFINED TH08_MACOS_BUNDLE OR NOT IS_DIRECTORY "${TH08_MACOS_BUNDLE}")
    message(FATAL_ERROR "TH08_MACOS_BUNDLE must name an existing .app directory.")
endif()

# BundleUtilities is intentionally used from script mode rather than project
# configure time. It recursively copies non-system dylibs into Frameworks,
# rewrites their install names, and verifies that the result is standalone.
include(BundleUtilities)
set(BU_CHMOD_BUNDLE_ITEMS TRUE)
fixup_bundle(
    "${TH08_MACOS_BUNDLE}"
    ""
    "${TH08_MACOS_DEPENDENCY_DIRS}"
)
