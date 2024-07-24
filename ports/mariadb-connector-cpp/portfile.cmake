vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mariadb-corporation/mariadb-connector-cpp
    REF ${VERSION}
    HEAD_REF master
    SHA512 efc0d7866b76b1baa20ab6bbbeb45825ca5e3d8b460e09805343f0e6b638bb0cfcd812d01bd183c5c0077eece5f1bdd5f207e753aa54b5ed218576b7cb37b241
    PATCHES
        fix-carray.diff
        libmariadb.diff
        install.diff
)


vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS
        -DINSTALL_LIBDIR=lib
        -DUSE_SYSTEM_INSTALLED_LIB=ON
        -DWITH_MSI=OFF
        -DWITH_UNIT_TESTS=OFF
)

vcpkg_cmake_install()

file(INSTALL "${CURRENT_PORT_DIR}/unofficial-${PORT}-config.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/unofficial-${PORT}")
vcpkg_cmake_config_fixup(PACKAGE_NAME "unofficial-${PORT}")

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
    "${CURRENT_PACKAGES_DIR}/share/doc"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
