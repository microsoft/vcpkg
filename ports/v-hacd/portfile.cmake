# Header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO kmammou/v-hacd
    REF "v${VERSION}"
    SHA512 b974c490897a1901d6975c75222a167a70f9e2a37e0c548aeb6a346cb0154ec1415947d47d69a729c0c4d9345aed70d3c09d4bf297beacfae66ceb4c8c89c6d0
    HEAD_REF master
)

file(INSTALL "${SOURCE_PATH}/include/VHACD.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
