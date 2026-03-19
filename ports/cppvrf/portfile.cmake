vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Microsoft/cppvrf
    REF "v${VERSION}"
    SHA512 518c97a06e8728e21702521aa1999589e33c1ce1f245a7efca72c9e79fa5449376b95577365aaaad95b5560f0e60241884b9406133fd92ff462423e0a81e7c8d
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
