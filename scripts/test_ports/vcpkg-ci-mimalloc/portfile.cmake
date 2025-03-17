set(VCPKG_POLICY_EMPTY_PACKAGE enabled)

vcpkg_find_acquire_program(PKGCONFIG)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO microsoft/mimalloc
    REF "v${VERSION}-beta"
    SHA512 a30de118b7afd9f3b66431c707432de752085ad0360b1db085736154fa4071ed643a39ff11842168c44c366a8f93c2093cb88d47177a178740089319365d77f8
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
