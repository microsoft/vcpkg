vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KhronosGroup/SPIRV-Reflect
    REF "vulkan-sdk-${VERSION}"
    SHA512 ee8abc9958af8887300eece7dbcf11ed4bf79d9ee281318e6794f093a988438736e0da642d61b975912475cc3a0b13fe8cd17d3a6b0fcfff653c9831f5d86ba0
    HEAD_REF main
    PATCHES
        export-targets.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DSPIRV_REFLECT_STATIC_LIB=ON
        -DSPIRV_REFLECT_EXAMPLES=OFF
        -DSPIRV_REFLECT_BUILD_TESTS=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME unofficial-spirv-reflect)

vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/spirv-reflect/spirv_reflect.h" "./include/spirv/unified1/spirv.h" "spirv.h")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

vcpkg_copy_tools(TOOL_NAMES spirv-reflect-pp spirv-reflect AUTO_CLEAN)
