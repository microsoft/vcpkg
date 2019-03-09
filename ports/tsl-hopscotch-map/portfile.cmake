include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Tessil/hopscotch-map
    REF v2.2.0
    SHA512 a3cd0fe47ff16de6d556c24e0bd96e420c1f06f2e44388e4f223fd8cf30a6cf0af20ade46af46f8cb5bbfd86a0fce2ca65658999cc2c14f4998d949f12afff2f
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
