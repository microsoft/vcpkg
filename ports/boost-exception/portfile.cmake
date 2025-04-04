# Automatically generated by scripts/boost/generate-ports.ps1

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO boostorg/exception
    REF boost-${VERSION}
    SHA512 f9b3728b4a81fd83b87b2d993afd9bd83c099a63305150f38410cf8eb33325b343a3a905b1556e5bf138784b226ac24ad60e7f78532f8989a44895e8ca158a0f
    HEAD_REF master
)

set(FEATURE_OPTIONS "")
include("${CMAKE_CURRENT_LIST_DIR}/features.cmake")
boost_configure_and_install(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS ${FEATURE_OPTIONS}
)
