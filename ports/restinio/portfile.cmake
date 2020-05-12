vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO stiffstream/restinio
    REF 00a6e8782ee0a818a52ce00f6ace4efc90dbc892 # v.0.6.7.1
    SHA512 93185dd590dd785141f47064572bcc53d32cc063fb08f9dce1e03ef5228561dba3a3ce29b45752b74eb2f299d1219ad022aa735344e8ed9fe14ffcaa6f82c6df
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}/vcpkg
    PREFER_NINJA
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/restinio)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib ${CURRENT_PACKAGES_DIR}/debug)
# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
