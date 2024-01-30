vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO likle/cwalk
    REF "v${VERSION}"
    SHA512 704133fb83beebc5942da5674b5f3563c64ec7017b33570a1f1433aa820a86882c42b16832efc215cd74f619a0a45493748655aa5af97bd3ff82d62f34b68f69
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DENABLE_TESTS=OFF
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/cwalk)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(INSTALL "${SOURCE_PATH}/LICENSE.md" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
