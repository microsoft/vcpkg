set(VCPKG_POLICY_EMPTY_PACKAGE enabled)

vcpkg_find_acquire_program(PKGCONFIG)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO microsoft/mimalloc
    REF "v${VERSION}"
    SHA512 4e30976758015c76a146acc1bfc8501e2e5c61b81db77d253de0d58a8edef987669243f232210667b32ef8da3a33286642acb56ba526fd24c4ba925b44403730
    HEAD_REF master
    PATCHES
        vcpkg-tests.patch
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
