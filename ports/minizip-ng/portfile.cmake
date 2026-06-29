if (VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO zlib-ng/minizip-ng
    REF "${VERSION}"
    SHA512 9ea5dde14acd2f7d1efd0e38b11017b679d3aaabac61552f9c5f4c7f45f2563543e0fbb2d74429c6b1b9c37d8728ebc4f1cf0efad5f71807c11bb8a2a681a556
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
        zstd    MZ_ZSTD
)

# Select the zlib flavor explicitly. minizip-ng's "auto" mode searches for
# zlib-ng first and then falls back to zlib; pinning MZ_ZLIB_FLAVOR ensures we
# build against whichever library the selected feature pulled in.
if("zlib-ng" IN_LIST FEATURES)
    set(ZLIB_OPTIONS -DMZ_ZLIB=ON -DMZ_ZLIB_FLAVOR=zlib-ng)
elseif("zlib" IN_LIST FEATURES)
    set(ZLIB_OPTIONS -DMZ_ZLIB=ON -DMZ_ZLIB_FLAVOR=zlib)
else()
    set(ZLIB_OPTIONS -DMZ_ZLIB=OFF)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        ${ZLIB_OPTIONS}
        -DMZ_FETCH_LIBS=OFF
        -DMZ_LIB_SUFFIX=-ng
        -DMZ_ICONV=OFF
)

vcpkg_cmake_install()

vcpkg_fixup_pkgconfig()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/minizip-ng)
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
