if(VCPKG_TARGET_IS_LINUX)
    message("Warning: `sparrow-extensions` requires Clang18+ or GCC 11.2+ on Linux")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO QuantStack/sparrow-extensions
    REF "${VERSION}"
    SHA512 1592ac6239e8e8d99ab31b40c75bd68d9a6c162761b249aa50608af2930ac9bbd973d732cf77d8622edeb1b1129da60e0253bedeb2f931555681937ef50330a6
    HEAD_REF main
)

if (VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    set(SPARROW_EXTENSIONS_BUILD_SHARED ON)
else()
    set(SPARROW_EXTENSIONS_BUILD_SHARED OFF)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DSPARROW_EXTENSIONS_BUILD_SHARED=${SPARROW_EXTENSIONS_BUILD_SHARED}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME sparrow-extensions CONFIG_PATH share/cmake/sparrow-extensions)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
