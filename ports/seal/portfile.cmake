string(REGEX REPLACE "^([0-9]+\\.[0-9]+)\\..*$" "\\1" VERSION_MAJOR_MINOR "${VERSION}")

if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO microsoft/SEAL
    REF "v${VERSION}"
    SHA512 99f7c46cb6e84607567c87af16db3cdcdb0633d57c373e023f85005493480e6c5d465c9f527a0c50b82b70827d175657d74b5cde1d7dc2be8e7e1d576ff3d4c4
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

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/SEAL-${VERSION_MAJOR_MINOR})

file(COPY "${CURRENT_PACKAGES_DIR}/include/SEAL-${VERSION_MAJOR_MINOR}/seal" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

# Provides pkg-config files only on UNIX.
if(NOT VCPKG_TARGET_IS_WINDOWS)
    vcpkg_fixup_pkgconfig()
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
