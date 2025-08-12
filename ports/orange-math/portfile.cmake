if (VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO orange-cpp/omath
    REF "v${VERSION}"
    SHA512 a371cf9061841c5cff5a965b8331af91efdee6bf57e7ac9181c641d75c3b7f7e39df4af8ed245c025dcea8b4b10f85cd3c63738ca1027f4a59e686b9378e838a
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
