vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO coin-or/CppAD
    REF "${VERSION}"
    SHA512 d4eaa8fc4ba5d059009c15bf30dd0ec3f1a14515dfb514de630b5df371fd351524af7d9cfc09d6f9155c09a1d92ad5e41f426377f720d056f04d8491a5eb5abd
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS
        -Dcppad_prefix=${CURRENT_PACKAGES_DIR}
    OPTIONS_RELEASE
        -Dcmake_install_libdirs=lib
    OPTIONS_DEBUG
        -Dcmake_install_libdirs=debug/lib
)

vcpkg_cmake_install()
vcpkg_fixup_pkgconfig()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/pkgconfig")

# Add the copyright
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
