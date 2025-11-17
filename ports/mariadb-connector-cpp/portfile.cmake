vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mariadb-corporation/mariadb-connector-cpp
    REF ${VERSION}
    HEAD_REF master
    SHA512 90ce780e19babda02608134c99e8c0e7601a41ee5531097735beb54ec94c2dd38ecf4f457e9cac04831d7e886fe7c7b7a6d9fe799bf71d52ba168158ec36dc67
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
