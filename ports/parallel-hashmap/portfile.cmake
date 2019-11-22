#header-only library
include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO greg7mdp/parallel-hashmap
    REF 1.24
    SHA512 1d5ad02651fc64ab7dcddfee21cc97055828a881c2933fde34d3de19af20ae4b92fb631918b382c3bffed81335752690555aa03d7b204f8c6d7230f8a22d6718
    HEAD_REF master
)

# Use greg7mdp/parallel-hashmap's own build process, skipping examples and tests
vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)
vcpkg_install_cmake()

# Delete redundant directories
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib ${CURRENT_PACKAGES_DIR}/debug ${CURRENT_PACKAGES_DIR}/share/doc)

file(COPY ${SOURCE_PATH}/phmap.natvis DESTINATION ${CURRENT_PACKAGES_DIR}/include)

# Put the licence file where vcpkg expects it
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/parallel-hashmap)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/parallel-hashmap/LICENSE ${CURRENT_PACKAGES_DIR}/share/parallel-hashmap/copyright)
