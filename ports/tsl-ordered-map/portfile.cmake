include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Tessil/ordered-map
    REF v0.8.1
    SHA512 c776fc82c971ec507f12fa071c5831bbbf94a0351f7ae936f60b73b91be2a264737b606a6be7bae0cc6b971f01c619a78dad3072ac603b26a2a13836184a8f3a
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
