vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO LMDB/lmdb
    REF 0c357cc88a00bda03aa4a982fc227a5872707df2 # LMDB_0.9.24
    SHA512 a4d4ff96078eaf608eff08014d56561903f113a32617d3c9327dcdedfb7b261e03a80bf705f9d7159bb065eb1ab3c95af49d42525b75de0c2953223377042dec
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
