vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jgaa/restc-cpp
    REF "v${VERSION}"
    SHA512 0f74d825d3958810c270748c2810953fe394d0bf1f147d81b9177803e29a86c702715d5995c5966c4fe671b7689f26d9a0fad4e82d111277bbd3ddce1a68f73a
    HEAD_REF master
    PATCHES
        0001-exclude-cmake-external-projects.patch

        # This patch is a combination of these two commits:
        # https://github.com/jgaa/restc-cpp/commit/f6144b1a93a00e11335e2cfa724da91925b08adb
        # https://github.com/jgaa/restc-cpp/commit/5470ee36b973fac960b3566e47efe873c21b43fa
        boost-1.86-fix.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        openssl       RESTC_CPP_WITH_TLS
        zlib          RESTC_CPP_WITH_ZLIB
        threaded-ctx  RESTC_CPP_THREADED_CTX
        boost-log     RESTC_CPP_LOG_WITH_BOOST_LOG
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
