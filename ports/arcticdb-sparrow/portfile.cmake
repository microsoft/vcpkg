if(VCPKG_TARGET_IS_LINUX)
    message("Warning: `sparrow` requires Clang18+ or GCC 12+ on Linux")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO man-group/sparrow
    REF "${VERSION}"
    SHA512 587c7b5abea6eb856d0bd664e23d63ae4878f3b2991de4b014221096eb5ee0844bafe2c0ca18f58ad19b564073a1c07a70297ae40d4635534e44d23c539f5efa
    HEAD_REF main
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        date                  USE_DATE_POLYFILL
        large-int-placeholder USE_LARGE_INT_PLACEHOLDERS
)

if (VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    set(SPARROW_BUILD_SHARED ON)
else()
    set(SPARROW_BUILD_SHARED OFF)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DSPARROW_BUILD_SHARED=${SPARROW_BUILD_SHARED}
        -DBUILD_TESTS=OFF
        -DBUILD_EXAMPLES=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME sparrow CONFIG_PATH share/cmake/sparrow)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
