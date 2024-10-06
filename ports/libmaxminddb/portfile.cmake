vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO maxmind/libmaxminddb
    REF "${VERSION}"
    SHA512 52a34cf6d825884749695dfc2af90c4e333650cc83909f2bb83e16fc5ca43b92e0d08623434bbb7844212618f8e0ec0b793f8e648ba81ce4e3cb11faa875be71
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTING=OFF
        -DCMAKE_SHARED_LIBRARY_PREFIX=lib
        -DCMAKE_STATIC_LIBRARY_PREFIX=lib
    OPTIONS_DEBUG
        -DCMAKE_DEBUG_POSTFIX=d
)
vcpkg_cmake_install()
vcpkg_copy_pdbs()

vcpkg_fixup_pkgconfig()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/maxminddb PACKAGE_NAME maxminddb)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

# Handle copyright
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
