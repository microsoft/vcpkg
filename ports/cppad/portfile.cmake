vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO coin-or/CppAD
    REF "${VERSION}"
    SHA512 a2e9b90246a78319d2a50347e03ee7a4e807e059200d834290981b5fc4ff99e1964c420f606a36b6cacb21d5b254f34edbafa660242b260a828e2259686f40cd
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
