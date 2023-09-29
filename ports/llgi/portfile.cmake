vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO altseed/LLGI
    REF 008fe7fc7d1c427f476c2e8ca654c590cd38c39a
    SHA512 6d4e284bec2b5ef166fe1c12c235e8c41c03a2994756b434a3d1c902450b380fda8d3251424c1fe5200559e7d4285009563d6922f9e9278fdbaa8340576308eb
    HEAD_REF master
    PATCHES
        fix-cmake.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        vulkan  BUILD_VULKAN
        vulkan  BUILD_VULKAN_COMPILER
        tool    BUILD_TOOL
)

string(COMPARE EQUAL "${VCPKG_CRT_LINKAGE}" "dynamic" USE_DYNAMIC_RUNTIME)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        ${FEATURE_OPTIONS}
        -DBUILD_TEST=OFF
        -DUSE_CREATE_COMPILER_FUNCTION=OFF
        -DUSE_THIRDPARTY_DIRECTORY=OFF
        -DUSE_MSVC_RUNTIME_LIBRARY_DLL=${USE_DYNAMIC_RUNTIME}
        -DGLSLANG_WITHOUT_INSTALL=OFF
        -DSPIRVCROSS_WITHOUT_INSTALL=OFF
        -DBUILD_TEST=OFF
)
vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH "lib/cmake")

if("tool" IN_LIST FEATURES)
    vcpkg_copy_tools(TOOL_NAMES ShaderTranspiler AUTO_CLEAN)
endif()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
    "${CURRENT_PACKAGES_DIR}/debug/bin"
    "${CURRENT_PACKAGES_DIR}/bin"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")