#header-only library
include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO greg7mdp/parallel-hashmap
    REF 1.2
    SHA512 2d82471529d3f75bedbd643a1e18cfe2c4ce05dedf8b750f75b29a19a5c3c38234076d17f4e46404cc632de19e956e58da60aeaf20bdc6c467173e11bbb0ba06
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

# Put the licence file where vcpkg expects it
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/parallel-hashmap)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/parallel-hashmap/LICENSE ${CURRENT_PACKAGES_DIR}/share/parallel-hashmap/copyright)
