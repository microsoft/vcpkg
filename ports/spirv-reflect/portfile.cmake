vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KhronosGroup/SPIRV-Reflect
    REF "vulkan-sdk-${VERSION}"
    SHA512 5de92dbd04424fb09f6c2a4c890572b2789017b737822d5bc8ab713aeede0796cdcc7ffe74e3ffe25cdd4c626e94bd60757e1cc625ede02b8fe3994b07588b44
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
