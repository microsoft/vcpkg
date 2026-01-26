if(VCPKG_TARGET_IS_LINUX)
    message("Warning: `sparrow-extensions` requires Clang18+ or GCC 11.2+ on Linux")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO QuantStack/sparrow-extensions
    REF "${VERSION}"
    SHA512 1b17743570382c418bba43a1fc343c3811250bd505940e66c6a94a79a2e545ad1e0c425fd27cd637cf0c36c0f738fb8dc002640d29b5c2db9d0441846fca6b5f
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
