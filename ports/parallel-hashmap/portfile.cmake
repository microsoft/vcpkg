#header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO greg7mdp/parallel-hashmap
    REF "v${VERSION}"
    SHA512 cf7892194b518cc207558bc024469bb3c345e427b71f4ecaaa7ec5ba30cd23005d005d80295edc7bf3a0805a4c1c747d6eec855fdc4828ccdc3adb5ffa1d8c6b
    HEAD_REF master
)

# Use greg7mdp/parallel-hashmap's own build process, skipping examples and tests
vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DPHMAP_BUILD_TESTS=OFF
        -DPHMAP_BUILD_EXAMPLES=OFF
)
vcpkg_cmake_install()

# Delete redundant directories
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib ${CURRENT_PACKAGES_DIR}/debug ${CURRENT_PACKAGES_DIR}/share/doc)

file(COPY ${SOURCE_PATH}/phmap.natvis DESTINATION ${CURRENT_PACKAGES_DIR}/include)

# Put the licence file where vcpkg expects it
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
