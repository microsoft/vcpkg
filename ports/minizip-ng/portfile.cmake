if (VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO zlib-ng/minizip-ng
    REF "${VERSION}"
    SHA512 606962a5939103d6045e05742f56d7a000708ee41a021dcd2583c534ab5944eb5d81c09bde37d891eaed8bdd6263513e94e73f89628225a68e36675342eb70d8
    HEAD_REF master
    PATCHES
        dependencies.diff
)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        pkcrypt MZ_PKCRYPT
        wzaes   MZ_WZAES
        openssl MZ_OPENSSL
        bzip2   MZ_BZIP2
        lzma    MZ_LZMA
        zlib    MZ_ZLIB
        zstd    MZ_ZSTD
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DMZ_PPMD=OFF
        -DMZ_FETCH_LIBS=OFF
        -DMZ_LIB_SUFFIX=-ng
        -DMZ_ICONV=OFF
        -DCMAKE_DISABLE_FIND_PACKAGE_ZLIBNG=ON # minizip-ng 4.0.10 searches for zlib-ng first before zlib - we provide zlib
)

vcpkg_cmake_install()

vcpkg_fixup_pkgconfig()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/minizip-ng)
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
