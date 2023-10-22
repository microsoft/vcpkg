vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO microsoft/SEAL
    REF 206648d0e4634e5c61dcf9370676630268290b59  #v4.1.1
    SHA512 8aa2dd06766bbc482c0e10d1c8a8379b3cd9bdc08ed93ae24f5c996ff2417f2df228e576309c521e2bd2c452d50014376f8183d2272c3af74bcc6f292ae7408b
    HEAD_REF main
    PATCHES
        shared-zstd.patch
)

vcpkg_replace_string(
    "${SOURCE_PATH}/cmake/CheckCXXIntrinsicsSpecific.cmake"
    "check_cxx_source_runs"
    "check_cxx_source_compiles"
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
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS
        "-DSEAL_BUILD_DEPS=OFF"
        "-DSEAL_BUILD_EXAMPLES=OFF"
        "-DSEAL_BUILD_TESTS=OFF"
        "-DSEAL_BUILD_SEAL_C=OFF"
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/SEAL-4.1")

vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME "copyright")

vcpkg_copy_pdbs()
