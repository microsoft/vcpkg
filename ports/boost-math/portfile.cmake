# Automatically generated by scripts/boost/generate-ports.ps1

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO boostorg/math
    REF boost-${VERSION}
    SHA512 d89c0edac6b218140ebb5fa3c54711a3c9912038304ed03713dceb4506b1ea6f699d49bcf4ca5d1b02efe592890934a95bed88cc55e3f1d3f620723436593243
    HEAD_REF master
    PATCHES
        build-old-libs.patch
        opt-random.diff
)

set(FEATURE_OPTIONS "")
include("${CMAKE_CURRENT_LIST_DIR}/features.cmake")
boost_configure_and_install(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS ${FEATURE_OPTIONS}
)
