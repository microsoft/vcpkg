vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO eyalz800/zpp_bits
    REF "v${VERSION}"
    SHA512 52e3f4bfb41870adf29f2ff8383908eb5eec5baaebced193808cc68f5482d3aa8fce9685bda033b3ea4673b8cc9d1bc18050b62e9b929b99f5fec03135033b14
    HEAD_REF main
)

file(INSTALL "${SOURCE_PATH}/zpp_bits.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
