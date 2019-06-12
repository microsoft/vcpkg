include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Tessil/hopscotch-map
    REF v2.2.1
    SHA512 389fb09b6e47d8005d4a1b6c0db0c5f03de67686e9d4b97e473bf88f0c398d3118be0dcfdc5d509c082fd53f52f5d779d04c3d9bafe65c5eba11d03c62b60ddc
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
