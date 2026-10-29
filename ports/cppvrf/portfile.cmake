vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Microsoft/cppvrf
    REF "v${VERSION}"
    SHA512 832bc6864126807eaef76ecdaaaa8bc26fce9649b354a55f68a5fbba6611c9795eabcf511266cffc6cd9e7713792fa7ebae514907a352b9b9b9a59495bda7390
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
