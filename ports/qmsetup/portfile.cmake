vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO stdware/qmsetup
    REF 2f10ebc3723a9b03edf309611483ee643f10add7
    SHA512 a1a6e4d60f68ce910a4f897beca870109ff5fead250e3e194051e1760ab62c1a1ad3ef6b58d20f5cb08da8c50121c3d55da3f2b8600c99d3b96289613fb42214
    HEAD_REF master
)

set(VCPKG_BUILD_TYPE release) # header-only port

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/qmsetup)

vcpkg_copy_tools(TOOL_NAMES qmcorecmd AUTO_CLEAN)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
