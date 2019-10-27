include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO LMDB/lmdb
    REF LMDB_0.9.23
    SHA512 47466a96ce288d18d489acf1abf811aa973649848a4cac31f71e1f25ea781a055ebd6616d2d630214b2df2f146f12609c82d65be0196f49d6b46a6c96464e120
    HEAD_REF master
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/cmake/ DESTINATION ${SOURCE_PATH}/libraries/liblmdb)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}/libraries/liblmdb
    PREFER_NINJA
    OPTIONS_DEBUG
        -DLMDB_INSTALL_HEADERS=OFF
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets()

file(INSTALL ${SOURCE_PATH}/libraries/liblmdb/COPYRIGHT DESTINATION ${CURRENT_PACKAGES_DIR}/share/lmdb RENAME copyright)

vcpkg_copy_pdbs()
