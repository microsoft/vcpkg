if(VCPKG_TARGET_IS_LINUX)
    message("Warning: `sparrow` requires Clang18+ or GCC 11.2+ on Linux")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO man-group/sparrow
    REF "${VERSION}"
    SHA512 9076fa8ddf284f54bb94437b4e5242ef3b8ee4b4127512e8f18fe8798d5715a21acc8fe9402ec7dec2f272c0b1a832cb091640fd67b2bcbc4fa2fdc096e6c935
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
