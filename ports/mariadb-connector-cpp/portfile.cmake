vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mariadb-corporation/mariadb-connector-cpp
    REF ${VERSION}
    HEAD_REF master
    SHA512 54a9637608c3acefbbf1bd46e66b6368cc01759e2db2e6a8ae6c2c6ea95c8d7c457e940b60526128627d05ffe079ec64e60fe518beb8874825e126f0a23c6e79
    PATCHES
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
