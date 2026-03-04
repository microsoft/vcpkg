vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Microsoft/cppvrf
    REF "v${VERSION}"
    SHA512 286b52104a3067b73a28b7710484b077ad5ec69055416698e40a06cbb0ba76636d7bc1e6eea526f9fd637b39bb2f98cf33668ebbde1fac0ee3052a1b322295ff
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
