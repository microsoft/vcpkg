vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO nevergiveupcpp/obfuscxx
    REF v${VERSION}
    SHA512 5dee6c7d257a3bf4fb24e64f9459b4c9dd33f14d9c0c57847bd232d0d896d0c5b886eaaff2af15a9a98b96ae8f40f9c416af9b31a1207513427a42b9e925e892
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/obfuscxx)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
