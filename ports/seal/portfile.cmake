vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO microsoft/SEAL
    REF d045f1beff96dff0fccc7fa0c5acb1493a65338c
    SHA512 9b5d3c4342608d8e3d9826d3b52cbefc1c21eb0094d0cae4add8bb0960f931e9080f248eb8ad8385fc0a08e2a1da10020185148ffd2ef02e7a4fac879e27aa69
    HEAD_REF main
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        ms-gsl SEAL_USE_MSGSL
        zlib SEAL_USE_ZLIB
        zstd SEAL_USE_ZSTD
        hexl SEAL_USE_INTEL_HEXL
    INVERTED_FEATURES
        no-throw-tran SEAL_THROW_ON_TRANSPARENT_CIPHERTEXT
)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS
        "-DSEAL_BUILD_DEPS=OFF"
        "-DSEAL_BUILD_EXAMPLES=OFF"
        "-DSEAL_BUILD_TESTS=OFF"
        "-DSEAL_BUILD_SEAL_C=OFF"
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME "SEAL" CONFIG_PATH "lib/cmake/")

if("hexl" IN_LIST FEATURES)
    vcpkg_fixup_pkgconfig(SKIP_CHECK)
else()
    vcpkg_fixup_pkgconfig()
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME "copyright")

vcpkg_copy_pdbs()
