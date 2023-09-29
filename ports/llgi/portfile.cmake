vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

# see https://github.com/altseed/LLGI/pull/150
vcpkg_download_distfile(LLGI_PR_150_PATCH
    URLS "https://patch-diff.githubusercontent.com/raw/altseed/LLGI/pull/150.diff"
    FILENAME llgi-pr-150.patch
    SHA512 4843985b00f7515295b70357bd1787e810fdc3f23e3f832280e43d4b617483e825f4f6abd8f75c1c9364305999515c999e4dbb85b29eb62fcb8b5229002db244
)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO altseed/LLGI
    REF 008fe7fc7d1c427f476c2e8ca654c590cd38c39a
    SHA512 6d4e284bec2b5ef166fe1c12c235e8c41c03a2994756b434a3d1c902450b380fda8d3251424c1fe5200559e7d4285009563d6922f9e9278fdbaa8340576308eb
    HEAD_REF master
    PATCHES
        ${LLGI_PR_150_PATCH}
        fix-cmake-use-vcpkg.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        vulkan  BUILD_VULKAN
        vulkan  BUILD_VULKAN_COMPILER
        tool    BUILD_TOOL
)

string(COMPARE EQUAL "${VCPKG_CRT_LINKAGE}" "dynamic" USE_DYNAMIC_RUNTIME)

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