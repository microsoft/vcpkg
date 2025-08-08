vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO altseed/LLGI
    REF 8f8510e2dffa1d747ff6ebb0da341198e75291ec
    SHA512 d521b47f293b90faed28f9648facdfae327c6122ea6391683a08e48558fdf62ce0d3977f78aef3bc276d77ab19fc40ab3cc4d27311dd5a292e0884635fe7c9d3
    HEAD_REF master
    PATCHES
        fix-cmake-use-vcpkg.patch
        fix-sources.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        vulkan  BUILD_VULKAN
        vulkan  BUILD_VULKAN_COMPILER
        tool    BUILD_TOOL
)

string(COMPARE EQUAL "${VCPKG_CRT_LINKAGE}" "dynamic" USE_DYNAMIC_RUNTIME)

# linux build requires x11-xcb
vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DBUILD_TEST=OFF
        -DBUILD_EXAMPLE=OFF
        -DUSE_CREATE_COMPILER_FUNCTION=ON
        -DUSE_THIRDPARTY_DIRECTORY=OFF # prevent ExternalProject_Add
        -DUSE_MSVC_RUNTIME_LIBRARY_DLL:BOOL=${USE_DYNAMIC_RUNTIME}
        -DGLSLANG_WITHOUT_INSTALL=OFF
        -DSPIRVCROSS_WITHOUT_INSTALL=OFF
    MAYBE_UNUSED_VARIABLES
        USE_MSVC_RUNTIME_LIBRARY_DLL
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake")

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