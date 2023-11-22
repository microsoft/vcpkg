vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jeremy-rifkin/cpptrace
    REF "v${VERSION}"
    SHA512 9f551f63b55d437df58e6fae1e63d80194342611d87445f63ad0db7629445e2a5b20a115f4fea40ecf9f4336f9c969475e092a6c7a2cc39f5a75e8788b379a66
    HEAD_REF main
    # PATCHES
    #   libdwarf_fixes.patch
    #   uintptr_fix.patch
    #   runtime_destination.patch
)

vcpkg_list(SET options -DCPPTRACE_USE_EXTERNAL_LIBDWARF=On)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS ${options}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(
    PACKAGE_NAME "cpptrace"
    CONFIG_PATH "lib/cmake/cpptrace"
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
