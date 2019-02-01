include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Tessil/ordered-map
    REF v0.8.0
    SHA512 9e0cc8ea4d5731e89cb6d58a54394b4ab0378cb2488d9e462ad80facd8aa06e21aaa0f9b969fbd7ac22c99bae09ab7c6e7980857784aa0b1a3a2b0c216ffa79a
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug)

file(INSTALL ${SOURCE_PATH}/LICENSE 
     DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} 
     RENAME copyright
)
