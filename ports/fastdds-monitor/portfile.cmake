
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO eProsima/Fast-DDS-monitor
    REF "v${VERSION}"
    SHA512 5bc8a4c1b08f16b4abfc11c4d93e7f99a405684bc6e3f9ce395ddc192e8f430e7b2b7bec60df9e213485f7bd406ea8ebe63d56725485406581c86d185ac7d52e
    HEAD_REF master
    PATCHES
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${extra_opts}
)

vcpkg_cmake_install()
vcpkg_copy_tools(TOOL_NAMES fastdds_monitor AUTO_CLEAN)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(REMOVE "${CURRENT_PACKAGES_DIR}/LICENSE")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
