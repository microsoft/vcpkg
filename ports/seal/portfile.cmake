vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO microsoft/SEAL
    REF 79234726053c45eede688400aa219fdec0810bd8
    SHA512 634ad75d70f04cce220bfa9f6d13e8ddb293e8403ebd195e2c8b522b751a1a268021feea7843038037ed6d1b354b2e470ad565966a117613cf5371073afda9a4
    HEAD_REF main
    PATCHES
        gsl.patch
        shared-zstd.patch
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

vcpkg_cmake_config_fixup(PACKAGE_NAME "SEAL" CONFIG_PATH "lib/cmake/SEAL-3.7")

vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME "copyright")

vcpkg_copy_pdbs()
