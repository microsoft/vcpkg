vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO andrivet/ADVobfuscator
    REF "v${VERSION}"
    SHA512 71e10d509615db470f3e1f163e78730a77f935289a0e1c976d0625cd2e7c55c507ddd47eb34400afcf4c1b0372746da82164c8daea15a21d59685bff02f3fbcc
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTING=OFF
        -DBUILD_EXAMPLES=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
