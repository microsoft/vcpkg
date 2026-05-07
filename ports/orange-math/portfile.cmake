if (VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO orange-cpp/omath
    REF "v${VERSION}"
    SHA512 5393159d060d0bf08ef50fb77996f994f149110a43b0420fb45c599f7269ed247270068cca2813ba3fb743cfd9c4541073e0ecf60bf584c59133b009bf73b087
    HEAD_REF master
)

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
