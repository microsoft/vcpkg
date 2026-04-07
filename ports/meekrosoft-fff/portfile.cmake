set(VCPKG_BUILD_TYPE release) # Header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO meekrosoft/fff
    REF "v${VERSION}"
    SHA512 92890152f37e9e8b3961be2b8d2633f374ce1a16f4d78d8c6ea070a5ca35c08a75b71227465133b6ffd5bfb481246a73df4109f8b141fa83c7e22b0d31e6f903
    HEAD_REF master
)

file(INSTALL "${SOURCE_PATH}/fff.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
