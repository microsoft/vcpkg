vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KhronosGroup/SPIRV-Cross
    REF vulkan-sdk-${VERSION}
    SHA512 56172ce2a766ea83a04701a3253a17fb611c66e25303448d7ca34d507b0476f4d14420021066b382ae6f35a1b1ee4b35443e2e0475b468552f3bd1ad3413e3af
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
