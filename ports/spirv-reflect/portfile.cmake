vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KhronosGroup/SPIRV-Reflect
    REF "vulkan-sdk-${VERSION}"
    SHA512 0062021edd4694caf417674b3763f0a3361a29c29d399573579206c83054afbf3c999c08534bd234f818875b84711f3ce891ec2316949e29a8360c3c38ca079d
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
