vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO microsoft/LightGBM
    REF v${VERSION}
    SHA512 365ba4d875a5af318b8534165bd14d174619c335f18bbfce814b17c9d0c7405a593f77451699fbc65a46d3ea693c06731edc47a89a248aa752281f0335e1bb46
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
