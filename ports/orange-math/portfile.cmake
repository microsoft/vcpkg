if (VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_download_distfile(
    FIX_VECTOR_INCLUDE
    URLS https://github.com/orange-cpp/omath/commit/463532ba81030b3ed9ccfd6a277af0028c190bb3.patch?full_index=1
    FILENAME fix-vector-include-463532ba81030b3ed9ccfd6a277af0028c190bb3.patch
    SHA512 6ec747d3cd89fce54e26997ea3508cb9c6cbf9ee2d473a825ea0bf8d4ecfad6712217a348f4d43acc757e4ab2d865778163982b8c9e5c490946bb3e92679b8c6
)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO orange-cpp/omath
    REF "v${VERSION}"
    SHA512 42ecf51363be50e7382b9aebd03039f4e6ef855beaa227fbd354da6aad39e6cb328baf8ef8acf8eea551403fdd43a94980990c57cb70b408d065fa992bc68c72
    HEAD_REF master
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" OMATH_SHARED)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        "avx2"      OMATH_USE_AVX2
        "imgui"     OMATH_IMGUI_INTEGRATION
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DOMATH_USE_UNITY_BUILD=ON
        -DOMATH_BUILD_TESTS=OFF
        -DOMATH_THREAT_WARNING_AS_ERROR=OFF
        -DOMATH_BUILD_AS_SHARED_LIBRARY=${OMATH_SHARED}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/omath" PACKAGE_NAME "omath")
vcpkg_copy_pdbs()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
