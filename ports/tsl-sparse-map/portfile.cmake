include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Tessil/sparse-map
    REF v0.6.0
    SHA512 6a21ebbd3505a0b4bf199f24ae9262395392964457eb26edb39fd7aa82aec7fc74468f7615977c74a2f36332850a68e1d6a6e86d487c3dff7efa2b081fa2c8c5
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
