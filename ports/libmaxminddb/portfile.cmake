vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO maxmind/libmaxminddb
    REF "${VERSION}"
    SHA512 1ff3f22d40f9486089c598c0b57989879c006240f6782fe3ecd35f8bd0474323359f5ebafc000d046ec8d475da28411e632b7004bd6b3101ca2e4fed76f55af3
    HEAD_REF main
    PATCHES
        fix-link-thread.patch
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
