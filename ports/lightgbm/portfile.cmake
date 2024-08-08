vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO microsoft/LightGBM
    REF v${VERSION}
    SHA512 295ea23ec55164232f1dde6aa46bcfa616e2fe4852eb2e3492e681477a8d7757875d60379c4d463a35a6a9db56b1f4bce86b3a03bed56ea3d36aadb94a3b38eb
    PATCHES
        vcpkg_lightgbm_use_vcpkg_libs.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        gpu USE_GPU
        threadless USE_OPENMP_OFF
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    set(BUILD_STATIC_LIB "OFF")
else()
    set(BUILD_STATIC_LIB "ON")
endif()

# Set CMake option based on feature
set(OPENMP_OPTION "-DUSE_OPENMP=ON")
if("x${USE_OPENMP_OFF}" STREQUAL "xON")
    set(OPENMP_OPTION "-DUSE_OPENMP=OFF")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DBUILD_STATIC_LIB=${BUILD_STATIC_LIB}
        ${FEATURE_OPTIONS}
        ${OPENMP_OPTION}
)

vcpkg_cmake_install()

vcpkg_copy_tools(TOOL_NAMES lightgbm AUTO_CLEAN)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
