if(VCPKG_TARGET_IS_LINUX)
    message("Warning: `sparrow` requires Clang18+ or GCC 11.2+ on Linux")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO man-group/sparrow
    REF "${VERSION}"
    SHA512 bac882ec7ba583e76a6ce9bf7144ad57cdee216c75d48e056291c66eb5304b73f491f707d1e8bc2cfc86c69ea37865ed439616c892282607212fc638e95caf6c
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
