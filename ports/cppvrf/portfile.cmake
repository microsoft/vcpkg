vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Microsoft/cppvrf
    REF "v${VERSION}"
    SHA512 fa736e440a7eb9b43318a144230735a60a33ea8cdebf16d836b283046dba1dfc1f27f495f96639782e04a54d2e40ec9a9ee5a43b09c007d21062a0cd2e8f9545
    HEAD_REF main
)

vcpkg_cmake_configure(SOURCE_PATH "${SOURCE_PATH}")

vcpkg_cmake_install()

# Only take the minor and minor version from ${VERSION}.
string(REGEX MATCH "^[0-9]+\\.[0-9]+" VERSION_MAJOR_MINOR "${VERSION}")

vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/cppvrf-${VERSION_MAJOR_MINOR}")

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

file(
    INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
