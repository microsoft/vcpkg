vcpkg_from_github(
    OUT_SOURCE_PATH LIB_MARIADB_CPP_SOURCE_PATH
    REPO mariadb-corporation/mariadb-connector-cpp
    REF ${VERSION}
    HEAD_REF master
    SHA512 efc0d7866b76b1baa20ab6bbbeb45825ca5e3d8b460e09805343f0e6b638bb0cfcd812d01bd183c5c0077eece5f1bdd5f207e753aa54b5ed218576b7cb37b241
    PATCHES
        0001-use-vcpkg.patch
        0002-Add-install-command.patch
        0003-modify-configure_file-to-share.patch
        0004-modify-to-share2.patch
        0005-remove-force-build-with-mt.patch
        0006-add-include.patch
        0007-add-include2.patch
        0008-add-TARGET_INCLUDE_DIRECTORIES.patch
        0009-add-include3.patch
        0010-add-include4.patch
        0011-add-include5.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${LIB_MARIADB_CPP_SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME mariadbcpp)
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${LIB_MARIADB_CPP_SOURCE_PATH}/COPYING")