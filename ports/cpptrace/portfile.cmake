vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jeremy-rifkin/cpptrace
    REF "v${VERSION}"
    SHA512 207b01d8b9114806a98f04b769082ba9ef3c66bad11972279b337ec794a14839715aee9b1f22883208e42b23289f1c8b7c842f2ac1c9973d8e2de48621623760
    HEAD_REF main
    PATCHES
      libdwarf_fixes.patch
      uintptr_fix.patch
      runtime_destination.patch
)

vcpkg_list(SET options -DCPPTRACE_USE_SYSTEM_LIBDWARF=On)
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
  vcpkg_list(APPEND options -DCPPTRACE_STATIC=On)
endif()

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
