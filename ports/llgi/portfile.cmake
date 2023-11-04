vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO altseed/LLGI
    REF 1b6b59b9f5bc9f81b4c2af2333d69f6e23670b3e
    SHA512 c9011dee560897caf5ae53d8fa58869b774bd3bc7ce2e0cc4696ac034fc89a36adf3f5285e82cffe6430ca61f6509fd7fbadf5c77aef896c74e8d70e70ff4312
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