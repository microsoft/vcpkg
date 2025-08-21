vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO duilib/duilib
    REF 502ac62be82c2bc33cf0e8635782fb370c68b1e7
    SHA512 249d2b7ab5b830a4b7a69e52e2e141f14e59d6bad610c48c7c2e4a8a974e45ace94d5106ea9583053d8a8ce389854ccea7c62e32c3685d2f07fe26225ece5e5a
    HEAD_REF master
    PATCHES 
        "fix-arm-build.patch"
        "fix-encoding.patch"
        "enable-static.patch"
        "fix-include-path.patch"
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    NO_CHARSET_FLAG
    OPTIONS
        -DDUILIB_BUILD_EXAMPLES=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
