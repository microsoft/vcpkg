set(VCPKG_POLICY_EMPTY_PACKAGE enabled)

vcpkg_find_acquire_program(PKGCONFIG)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO microsoft/mimalloc
    REF "v${VERSION}"
    SHA512 fa47dd7ecfe8e8afb691490a3317ce89e92c4d322624d4373a113beb10d4aa44b43359fea84beb43ad9be5cddd4f262a5c933177c6096b70d2cee53cb6e9620b
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
