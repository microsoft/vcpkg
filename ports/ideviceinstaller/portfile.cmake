vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libimobiledevice/ideviceinstaller
    REF b9cfe0b264f66eab9ad88e11eb6b0523cb1de911 # commits on 2023-07-21
    SHA512 a78418001109593f2d704d91aff8df009e15c504c2139ca606c9719b70868466ef73778d52670468a4b7bf758ec65435c1b981c27809a2e22737f7587ad51c7d
    HEAD_REF master
    PATCHES
        001_fix_windows.patch
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_copy_tools(TOOL_NAMES ideviceinstaller AUTO_CLEAN)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")

set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)
