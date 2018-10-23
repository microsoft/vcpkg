include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO LMDB/lmdb
    REF LMDB_0.9.18
    SHA512 394e88d99d446eb30771d7cf7a661584683a0d6d8e976cc561b5eecbb2a5d0817bbd59994002afa4eae6c86a39f05f50ebc2eff77cd70dd8c67225df4611f5e6
    HEAD_REF master
    PATCHES lmdb_45a88275d2a410e683bae4ef44881e0f55fa3c4d.patch
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/cmake/ DESTINATION ${SOURCE_PATH}/libraries/liblmdb)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}/libraries/liblmdb
    OPTIONS_DEBUG
        -DLMDB_INSTALL_HEADERS=OFF
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH share/lmdb)

file(INSTALL ${SOURCE_PATH}/libraries/liblmdb/COPYRIGHT DESTINATION ${CURRENT_PACKAGES_DIR}/share/lmdb RENAME copyright)

vcpkg_copy_pdbs()