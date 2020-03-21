
vcpkg_fail_port_install(ON_TARGET "OSX" "UWP" "ANDROID" ON_LIBRARY_LINKAGE "dynamic")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO bkaradzic/bgfx
    REF 78675e238da3c690916f33064e69cfe4167b866d
    SHA512 90971bf89bafb84bf49235409b43cbf64537035bd272ed15c3a797e3e89f414cb82b86d642ce9f7184d492f0c6e1d5e21c2ca3710d3e47726c06bf7242f3b112
    HEAD_REF master
    PATCHES
        10-renderdoc-include.patch
        20-d3dx12-include.patch
        40-stb-include.patch
        50-cgltf-include.patch
        60-freetype-include.patch
        70-glslang-include.patch
)
file(COPY "${CURRENT_PORT_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}/")
file(COPY "${CURRENT_PORT_DIR}/bgfx-config.cmake.in" DESTINATION "${SOURCE_PATH}/")

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        opengl   BGFX_WITH_OPENGL
        opengl-core BGFX_WITH_OPENGL_CORE
        vulkan   BGFX_WITH_VULKAN
        d3d11    BGFX_WITH_D3D11
        d3d12    BGFX_WITH_D3D12
        examples BGFX_WITH_EXAMPLES
        tools    BGFX_WITH_TOOLING
    INVERTED_FEATURES
)

if (EXISTS "${SOURCE_PATH}/3rdparty/dxsdk")
    file(COPY # files which are not part of the winsdk
        "${SOURCE_PATH}/3rdparty/dxsdk/include/d3dx12.h"
        "${SOURCE_PATH}/3rdparty/dxsdk/include/pix3.h"
        "${SOURCE_PATH}/3rdparty/dxsdk/include/pix3_win.h"
        "${SOURCE_PATH}/3rdparty/dxsdk/include/PIXEventsCommon.h"
        "${SOURCE_PATH}/3rdparty/dxsdk/include/PIXEventsGenerated.h"

        DESTINATION "${SOURCE_PATH}/src/"
    )
endif()
# remove all 3rdparty libraries provided by vcpkg
# this is necessary, because we need to remove them from the include path
file(REMOVE_RECURSE
    "${SOURCE_PATH}/3rdparty/cgltf"
    "${SOURCE_PATH}/3rdparty/dxsdk"
    "${SOURCE_PATH}/3rdparty/freetype"
    "${SOURCE_PATH}/3rdparty/glslang"
    "${SOURCE_PATH}/3rdparty/spirv-cross"
    "${SOURCE_PATH}/3rdparty/spirv-headers"
    "${SOURCE_PATH}/3rdparty/spirv-tools"
    "${SOURCE_PATH}/3rdparty/stb"
)
# remaining vendored 3rdparty dependencies (all of them are only used for the example and tool executables)
#  * dear-imgui      -- heavily augmented
#  * fcpp            -- frexx C Preprocessor: http://daniel.haxx.se/projects/fcpp/
#  * glsl-optimizer  -- https://github.com/aras-p/glsl-optimizer
#  * iconfontheaders -- https://github.com/juliettef/IconFontCppHeaders
#  * meshoptimizer   -- https://github.com/zeux/meshoptimizer
#  * sdf             -- unknown origin

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS ${FEATURE_OPTIONS}
    OPTIONS_DEBUG
        -DBGFX_CONFIG_DEBUG=1
        -DBGFX_DISABLE_HEADER_INSTALL=ON
    OPTIONS_RELEASE
        -DBGFX_INSTALL_TOOLING=1
)

vcpkg_install_cmake()
if ("tools" IN_LIST FEATURES)
    file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools")
    file(RENAME "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/tools/${PORT}")
endif()

vcpkg_fixup_cmake_targets()

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
