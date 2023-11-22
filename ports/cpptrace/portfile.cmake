vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jeremy-rifkin/cpptrace
    REF "v${VERSION}"
    SHA512 b69104f5812da84f33a62b8e82dc6a36f7dc5dfdb7e438eadfb53499570d05903dd00b2dfa54005f5cb23f49066d31d2083d41231fefd7c6a3e7c2063a21a82e
    HEAD_REF main
    # PATCHES
    #   libdwarf_fixes.patch
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
