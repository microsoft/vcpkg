#header-only library
include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO greg7mdp/parallel-hashmap
    REF 1.22
    SHA512 930ad0a2fd95310bd2d99c858a09416ca1c02bb823a49f96ec38cfc9ec4029b95b3dc3eacff88dc93df2cad968008b2db3cbb1c458c6cceddc542bb0ca74fad9
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
