set(VCPKG_BUILD_TYPE "release") # header-only port

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO tlk00/BitMagic
    REF "v${VERSION}"
    SHA512 0efc2b8e0e6b4c10b71ea5a5f41756ef82fa213631a850155c7e427b6a2d18a9f5cbe58fbea81b4a59ae5ccba996bc9880b73069ac459fe54bdb25a13fdf689a
    HEAD_REF master
)

file(GLOB HEADER_LIST "${SOURCE_PATH}/src/*.h")
file(INSTALL ${HEADER_LIST} DESTINATION "${CURRENT_PACKAGES_DIR}/include/${PORT}")
vcpkg_install_copyright(
    FILE_LIST
        "${SOURCE_PATH}/LICENSE"
        "${SOURCE_PATH}/src/sse2neon.h"
)
