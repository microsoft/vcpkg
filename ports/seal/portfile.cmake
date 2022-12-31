vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO microsoft/SEAL
    REF a0fc0b732f44fa5242593ab488c8b2b3076a5f76  #v4.0.0
    SHA512 74c2f9ddbcdd93795185be8ccffda1b34fd75cb4f7458804a7faa97b6a8ce244c7b2ba9e1d918e685bf4dbde1ffc7be05232b3237acb6e3e54d822516633c837
    HEAD_REF main
    PATCHES
        gsl.patch
        shared-zstd.patch
        fix-find_package.patch
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

vcpkg_cmake_config_fixup(PACKAGE_NAME "SEAL" CONFIG_PATH "lib/cmake/SEAL-4.0")

vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME "copyright")

vcpkg_copy_pdbs()
