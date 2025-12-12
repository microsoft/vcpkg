vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO andrivet/ADVobfuscator
    REF "v${VERSION}"
    SHA512 da8396304e45be018e878ef09e063f4f21383d0093973eaa5abaf5c6f0e391cb69b5d71b0c08cd88c732cf038d0395e876e5933f1e1cd369e6b4ac9df0139814
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
