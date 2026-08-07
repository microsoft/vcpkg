vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mariadb-corporation/mariadb-connector-cpp
    REF ${VERSION}
    HEAD_REF master
    SHA512 af4659aef378b46eeb7d37388ccbab98d5e1b9d0044325750220dc1a7d1b11d15ab8203768712a359c1126fe753ac0bf893138e92a136f973698338c11cb2ab4
    PATCHES
        fix-carray.diff
        libmariadb.diff
        mingw.diff
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
