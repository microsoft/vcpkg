vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO an-dr/microlog
    REF "v7.1.0"
    SHA512 a3604c3019bde7ad1308df52a8b249f91d625138940a69252d7450de4c5ea6615f249294716a565bd144052c77acfadc5587f0b3d44a39523e7adb8cdcf2975d
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/microlog")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")
file(REMOVE "${CURRENT_PACKAGES_DIR}/LICENSE")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")