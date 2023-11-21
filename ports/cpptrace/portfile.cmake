vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jeremy-rifkin/cpptrace
    REF "v${VERSION}"
    SHA512 e85c6482c9d24a0ad9e53c63239a089ff7091af995d339add0268ee091b9357220f8c028b541c4bdeab996b7a71c11ca41d0ad6d8db607be7185289699574fbc
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
