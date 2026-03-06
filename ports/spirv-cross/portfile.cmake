vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KhronosGroup/SPIRV-Cross
    REF vulkan-sdk-${VERSION}
    SHA512 57904efacecb1e5266caa27f34f5d8693d4f357233c727b2e0e58d182287dfea5a71b1ac81fb33b9e30e5eb1c4cbf5aeeb7ca2f0865a74e32347b96f9f453ee6
    HEAD_REF master
)

if(VCPKG_TARGET_IS_IOS)
    message(STATUS "Using iOS triplet. Executables won't be created...")
    set(BUILD_CLI OFF)
else()
    set(BUILD_CLI ON)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DSPIRV_CROSS_EXCEPTIONS_TO_ASSERTIONS=OFF
        -DSPIRV_CROSS_CLI=${BUILD_CLI}
        -DSPIRV_CROSS_SKIP_INSTALL=OFF
        -DSPIRV_CROSS_ENABLE_C_API=ON
)
vcpkg_cmake_install()
vcpkg_copy_pdbs()
if(NOT VCPKG_BUILD_TYPE)
    if(VCPKG_TARGET_IS_WINDOWS)
        vcpkg_replace_string("${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/spirv-cross-c.pc" "-lspirv-cross-c" "-lspirv-cross-cd")
    endif()
    file(COPY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/spirv-cross-c.pc" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig")
endif()
vcpkg_fixup_pkgconfig()

foreach(COMPONENT core c cpp glsl hlsl msl reflect util)
    vcpkg_cmake_config_fixup(CONFIG_PATH share/spirv_cross_${COMPONENT}/cmake PACKAGE_NAME spirv_cross_${COMPONENT})
endforeach()

if(BUILD_CLI)
    vcpkg_copy_tools(TOOL_NAMES spirv-cross AUTO_CLEAN)
endif()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
