vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO yse/easy_profiler
    REF "v${VERSION}"
    SHA512 101d84a903315456ac24d060da6269e02ac0030e966b801910543c39980042e92082b2430daaa9ab48ced90fb5fc0adf43dfab647615742d32950a1667c3630f
    HEAD_REF develop
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DEASY_PROFILER_NO_GUI=ON
        -DEASY_PROFILER_NO_SAMPLES=ON
)

vcpkg_cmake_install()

vcpkg_copy_tools(
    TOOL_NAMES "profiler_converter"
    AUTO_CLEAN
)

vcpkg_cmake_config_fixup(
    CONFIG_PATH "lib/cmake/easy_profiler"
    PACKAGE_NAME easy_profiler
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE "${CURRENT_PACKAGES_DIR}/LICENSE.APACHE")
file(REMOVE "${CURRENT_PACKAGES_DIR}/LICENSE.MIT")
file(REMOVE "${CURRENT_PACKAGES_DIR}/debug/LICENSE.APACHE")
file(REMOVE "${CURRENT_PACKAGES_DIR}/debug/LICENSE.MIT")

vcpkg_install_copyright(
    FILE_LIST
        "${SOURCE_PATH}/LICENSE"
        "${SOURCE_PATH}/easy_profiler_core/LICENSE.MIT"
        "${SOURCE_PATH}/easy_profiler_core/LICENSE.APACHE"
)
