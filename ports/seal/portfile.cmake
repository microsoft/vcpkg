string(REGEX REPLACE "^([0-9]+\\.[0-9]+)\\..*$" "\\1" VERSION_MAJOR_MINOR "${VERSION}")

if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO microsoft/SEAL
    REF "v${VERSION}"
    SHA512 4da6f6264c060f34bd25413637fe8bc77618f484558e64ec22ae54c1adf268d5f46dd5738e16a3f2ea13a0e0127c623911d10dc6eb5bca92b038b8221368ce5f
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

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE" "${SOURCE_PATH}/NOTICE")
