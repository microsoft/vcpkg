vcpkg_from_github(
    OUT_SOURCE_PATH LIB_MARIADB_CPP_SOURCE_PATH
    REPO mariadb-corporation/mariadb-connector-cpp
    REF ${VERSION}
    HEAD_REF master
    SHA512 efc0d7866b76b1baa20ab6bbbeb45825ca5e3d8b460e09805343f0e6b638bb0cfcd812d01bd183c5c0077eece5f1bdd5f207e753aa54b5ed218576b7cb37b241
)

vcpkg_cmake_configure(
    SOURCE_PATH "${LIB_MARIADB_CPP_SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup()
vcpkg_copy_pdbs()

vcpkg_install_copyright(FILE_LIST "${LIB_MARIADB_CPP_SOURCE_PATH}/COPYING")