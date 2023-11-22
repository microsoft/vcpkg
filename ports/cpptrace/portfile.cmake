vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jeremy-rifkin/cpptrace
    REF "v${VERSION}"
    SHA512 fb1019da8f2de85f6fa7a8b08e16f16c755d7e94371bb23a7851b747db033913f2b42faf3afa6d0b1d338847746117cd8dd2dfe6d9fae7d9288176dfc1a8d720
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
