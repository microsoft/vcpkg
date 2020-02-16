#header-only library
include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO greg7mdp/parallel-hashmap
    REF 1.30
    SHA512 5c2f4d1f50a6dc17bd763243412786056d5ecc4ec801ac5fe5bacbf0e6abe30e17347f3e4a22c12dc293e74843920cbc9b19ec3f1a048f8a3f58626457cba32a
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
