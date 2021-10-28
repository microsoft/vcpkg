vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO microsoft/SEAL
    REF 2d2a25c916047d2f356d45ad50c98f0a9695905a
    SHA512 81b2be39fca39dbd3a1246d0a1b8474d27eb6b1f3205f2107243bcd883b95814d2b642fa6807ed1f272d321233c2ec7992a256866ae1700c1203575594b42559
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

vcpkg_cmake_config_fixup(PACKAGE_NAME "SEAL" CONFIG_PATH "lib/cmake/SEAL-3.7")

vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME "copyright")

vcpkg_copy_pdbs()
