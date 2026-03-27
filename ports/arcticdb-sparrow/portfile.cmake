if(VCPKG_TARGET_IS_LINUX)
    message("Warning: `sparrow` requires Clang18+ or GCC 11.2+ on Linux")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO man-group/sparrow
    REF "${VERSION}"
    SHA512 a3ce8cd0e059c0e546467f65806c7ab2c002f458e4f7ea447fde7a59f25a1cb62abceba82c1feea691b2153f1789ab4a49ae4825755730891dcc8d7889681bfa
    HEAD_REF main
)

if (VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    set(SPARROW_BUILD_SHARED ON)
else()
    set(SPARROW_BUILD_SHARED OFF)
endif()

# Check for features
if("json-reader" IN_LIST FEATURES)
    set(BUILD_JSON_READER ON)
else()
    set(BUILD_JSON_READER OFF)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DSPARROW_BUILD_SHARED=${SPARROW_BUILD_SHARED}
        -DCREATE_JSON_READER_TARGET=${BUILD_JSON_READER}
        -DUSE_DATE_POLYFILL=ON
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME sparrow CONFIG_PATH share/cmake/sparrow)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
