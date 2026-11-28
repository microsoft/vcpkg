if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO microsoft/SEAL
    REF "v${VERSION}"
    SHA512 3a4e239d336d6804b389496f12a00093f4aa5579b48dbb3ed0ef8d7b638245d0ef7d0a89dae435833cabf90e04619aa1b40413b0ca8d96cec343232e6c4e4b0b
    HEAD_REF main
    PATCHES
        shared-zstd.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        ms-gsl SEAL_USE_MSGSL
        zlib   SEAL_USE_ZLIB
        zstd   SEAL_USE_ZSTD
        hexl   SEAL_USE_INTEL_HEXL
    INVERTED_FEATURES
        no-throw-tran SEAL_THROW_ON_TRANSPARENT_CIPHERTEXT
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DSEAL_BUILD_DEPS=OFF
        -DSEAL_BUILD_EXAMPLES=OFF
        -DSEAL_BUILD_TESTS=OFF
        -DSEAL_BUILD_BENCH=OFF
        -DSEAL_BUILD_SEAL_C=OFF
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/SEAL)

# Provides pkg-config files only on UNIX.
if(NOT VCPKG_TARGET_IS_WINDOWS)
    vcpkg_fixup_pkgconfig()
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE" "${SOURCE_PATH}/NOTICE")
