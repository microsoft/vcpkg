vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO microsoft/LightGBM
    REF v${VERSION}
    SHA512 f968f984a0881a5eadd898dded367b799b619e3cc80415dec8b623897e84d7e1e1034f20179125354b93759ea1b8a3e334cfa506427442810ef098bc93fd4634
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
