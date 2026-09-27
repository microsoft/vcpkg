# Header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO tlk00/BitMagic
    REF "v${VERSION}"
    SHA512 2a7ac70a62a25662221afd9c6ff2e978492e7ecf913b480567ce0a105e46bcf3a9efe13e7c9276825ea0ea8d59ba9764ac2658bff6f52aefa7590d9decbc8fd0
    HEAD_REF master
)

file(GLOB HEADER_LIST "${SOURCE_PATH}/src/*.h")
file(INSTALL ${HEADER_LIST} DESTINATION "${CURRENT_PACKAGES_DIR}/include/${PORT}")
vcpkg_install_copyright(
    FILE_LIST
        "${SOURCE_PATH}/LICENSE"
        "${SOURCE_PATH}/src/sse2neon.h"
)
