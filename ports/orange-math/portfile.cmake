if (VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_download_distfile(ARCHIVE
    URLS "https://git.libomath.org/orange/omath/archive/v${VERSION}.tar.gz"
    FILENAME "omath-${VERSION}.tar.gz"
    SHA512 5cd4d18220a6d233ac16dce3e03a6bf128b2552887a9616fcfb1c0b287ef95a6871912f19be462871d0eb408d1abbd11aa370e506495ec67e8554e28a9184484
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
)

# The release archive's VERSION file can lag behind its tag.
file(WRITE "${SOURCE_PATH}/VERSION" "${VERSION}")

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" OMATH_SHARED)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        "avx2"      OMATH_USE_AVX2
        "imgui"     OMATH_IMGUI_INTEGRATION
        "inline"    OMATH_ENABLE_FORCE_INLINE
        "hooking"   OMATH_ENABLE_HOOKING
        "lua"       OMATH_ENABLE_LUA
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DOMATH_USE_UNITY_BUILD=OFF
        -DOMATH_THREAT_WARNING_AS_ERROR=OFF
        -DOMATH_BUILD_AS_SHARED_LIBRARY=${OMATH_SHARED}
        -DOMATH_BUILD_TESTS=OFF
        -DOMATH_BUILD_BENCHMARK=OFF
        -DOMATH_BUILD_EXAMPLES=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/omath" PACKAGE_NAME "omath")
vcpkg_copy_pdbs()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
