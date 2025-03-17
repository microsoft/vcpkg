if(VCPKG_TARGET_IS_LINUX)
    message("Warning: `sparrow` requires Clang18+ or GCC 12+ on Linux")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO man-group/sparrow
    REF "${VERSION}"
    SHA512 1e80792625589c72a8e83cabc603f0f4e08ce72c6ba9044e2191f197e7740ac40f7b714c5fe543a00417689e48c681d5ea4f81b87baf54695f3725acf1d3a0e3
    HEAD_REF main
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
