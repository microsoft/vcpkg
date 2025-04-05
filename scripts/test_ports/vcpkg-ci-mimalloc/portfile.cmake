set(VCPKG_POLICY_EMPTY_PACKAGE enabled)

vcpkg_find_acquire_program(PKGCONFIG)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO microsoft/mimalloc
    REF "v${VERSION}"
    SHA512 404a7827aea6f39bb4b9d43b5c93d5ca39e84e29bf362d597744703f7a6d0c091f55b45a070e6d61ad7f68bf7c28f541668c75db16bae1423bd318f47bf06974
    HEAD_REF master
    PATCHES
        vcpkg-tests.patch
        non-win32.diff
)
# Ensure that the test uses the installed mimalloc only
file(REMOVE_RECURSE
    "${SOURCE_PATH}/bin"
    "${SOURCE_PATH}/include"
    "${SOURCE_PATH}/src"
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/test"
    OPTIONS
        "-DPKG_CONFIG_EXECUTABLE=${PKGCONFIG}"
        "-DVCPKG_TESTS=${CURRENT_PORT_DIR}/vcpkg-tests.cmake"
)
vcpkg_cmake_install(ADD_BIN_TO_PATH)

vcpkg_copy_tools(TOOL_NAMES pkgconfig-override-cxx AUTO_CLEAN)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
