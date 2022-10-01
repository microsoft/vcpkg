#header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO greg7mdp/parallel-hashmap
    REF 1.36
    SHA512 c5f7eea4cda698b8a2cc405d061fa1f4746354d5b0d3edd4db2e571fed757ffffe21c5ad4ec45feaa72db0dd092c7d220505f378340caeb176685900a57bc24c
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
