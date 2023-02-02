vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO LMDB/lmdb
    REF 8ad7be2510414b9506ec9f9e24f24d04d9b04a1a # LMDB_0.9.29
    SHA512 a18b6217761bdfcc5964d9817addd2d0c6c735d02a823717eb7ae1561a48110da0708a3290e21297d481e4d8eeb5d92a4a6860ff44888bf2da665cd9f167513c
    HEAD_REF master
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/cmake/" DESTINATION "${SOURCE_PATH}/libraries/liblmdb")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/libraries/liblmdb"
    OPTIONS_DEBUG
        -DLMDB_INSTALL_HEADERS=OFF
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL "${SOURCE_PATH}/libraries/liblmdb/COPYRIGHT" DESTINATION "${CURRENT_PACKAGES_DIR}/share/lmdb" RENAME copyright)

vcpkg_copy_pdbs()
