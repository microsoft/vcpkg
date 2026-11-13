vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jona62/TaskDaemon-Handlers
    REF "v${VERSION}"
    SHA512 114f0308c00429e16c6899bfeab11ef05dd0900a8f4305720f5671dcbb4f229adbca10b8119c0441940a6041be9c3d335720d27a750bc4f727d1602c149a15bc
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/cpp"
    OPTIONS -DTASKDAEMON_BUILD_TESTS=OFF
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME taskdaemon CONFIG_PATH lib/cmake/taskdaemon)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug" "${CURRENT_PACKAGES_DIR}/lib")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/cpp/LICENSE")
