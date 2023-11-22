vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jeremy-rifkin/cpptrace
    REF "v${VERSION}"
    SHA512 9cf82154e32df5123ed1cacbb6c5f867a66fde47747832eb6ec10729640844b5547db9575f20c37afa808e52a893d55a45cb956c6735875deff7a1f4156554d3
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
