vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO lightgbm-org/LightGBM
    REF v${VERSION}
    SHA512 5a6dd22447d7695fc65a0e0a2ced0a09e29a1500ce922da6d246afa16adaaf226561e9c155b0454fe2a48abc81065d1289ab0a2182f7cb28a72405ad032e9627
    PATCHES
        vcpkg_lightgbm_use_vcpkg_libs.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        gpu USE_GPU
        openmp USE_OPENMP
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    set(BUILD_STATIC_LIB "OFF")
else()
    set(BUILD_STATIC_LIB "ON")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DBUILD_STATIC_LIB=${BUILD_STATIC_LIB}
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()

vcpkg_copy_tools(TOOL_NAMES lightgbm AUTO_CLEAN)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
