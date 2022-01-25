#header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO greg7mdp/parallel-hashmap
    REF 1.33
    SHA512 287f098229153d925632e68e3cdbabfae0ea0ab8864089e4c0553a166c6079ca82ed5246ba53afd2a2917abcf06f37bc18f098e721f5f3b8def4d2d8c1c8c745
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
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
