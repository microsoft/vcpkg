vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_download_distfile(
    PATCH1_FILE
    URLS https://github.com/jgaa/restc-cpp/commit/d534d95b8c2c0c3786d2ad10bd2c9f2d7d2c83c5.patch?full_index=1
    SHA512 07a09a0685f89b75f6f41c660cb4da6897f718cb11e588d353f24225ac0b0c1f75ad972cf0dc9f6c754b6aa1c4a40fc08f2a3d8d43a2e64ebfbb66453ceec43d
    FILENAME d534d95b8c2c0c3786d2ad10bd2c9f2d7d2c83c5.patch
)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jgaa/restc-cpp
    REF "v${VERSION}"
    SHA512 c0c3795161654b91283b1536ba744ce50be248ebd68c2c28a1d29783d06adcfea16b1ca5b1eff27ff62f8bb347fbf3f56c6b49ee5b5875eb4eecf6824caca129
    HEAD_REF master
    PATCHES
        "${PATCH1_FILE}"
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        openssl       RESTC_CPP_WITH_TLS
        zlib          RESTC_CPP_WITH_ZLIB
        threaded-ctx  RESTC_CPP_THREADED_CTX
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    WINDOWS_USE_MSBUILD
    OPTIONS
        -DINSTALL_RAPIDJSON_HEADERS=OFF
        -DRESTC_CPP_WITH_EXAMPLES=OFF
        -DRESTC_CPP_WITH_UNIT_TESTS=OFF
        -DRESTC_CPP_WITH_FUNCTIONALT_TESTS=OFF
        -DRESTC_CPP_USE_CPP17=ON
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/${PORT}")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share"
                    "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
