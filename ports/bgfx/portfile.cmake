if(VCPKG_TARGET_IS_WINDOWS)
  vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_download_distfile(
  ARCHIVE_FILE
  URLS https://github.com/bkaradzic/bgfx.cmake/releases/download/v${VERSION}/bgfx.cmake.v${VERSION}.tar.gz
  FILENAME bgfx.cmake.v${VERSION}.tar.gz
  SHA512 520c542b65e76e92eae818e32eeb62bb2347ac89a1e10fc07cd5059a3b8a9a543cadca87d451a3bc157c415f6183b1f0e5031248e38fae704b8efd54679d482b
)

vcpkg_extract_source_archive(
  SOURCE_PATH
  ARCHIVE "${ARCHIVE_FILE}"
  PATCHES
    fix-dependencies.patch
)
file(REMOVE_RECURSE
  "${SOURCE_PATH}/bgfx/3rdparty/dear-imgui"
  "${SOURCE_PATH}/bgfx/3rdparty/glslang"
  "${SOURCE_PATH}/bgfx/3rdparty/meshoptimizer"
  "${SOURCE_PATH}/bgfx/3rdparty/spirv-cross"
  "${SOURCE_PATH}/bgfx/3rdparty/spirv-headers"
  "${SOURCE_PATH}/bgfx/3rdparty/spirv-opt"
  "${SOURCE_PATH}/bgfx/3rdparty/stb"
  "${SOURCE_PATH}/bimg/3rdparty/libsquish"
  "${SOURCE_PATH}/bimg/3rdparty/lodepng"
  "${SOURCE_PATH}/bimg/3rdparty/stb"
  "${SOURCE_PATH}/bimg/3rdparty/tinyexr"
)

vcpkg_check_features(
  OUT_FEATURE_OPTIONS FEATURE_OPTIONS
  FEATURES
    tools         BGFX_BUILD_TOOLS
    multithreaded BGFX_CONFIG_MULTITHREADED
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
  set(BGFX_LIBRARY_TYPE "SHARED")
else ()
  set(BGFX_LIBRARY_TYPE "STATIC")
endif ()

vcpkg_cmake_configure(
  SOURCE_PATH "${SOURCE_PATH}"
  OPTIONS
    -DBGFX_LIBRARY_TYPE=${BGFX_LIBRARY_TYPE}
    -DBGFX_AMALGAMATED=ON
    -DBGFX_BUILD_EXAMPLES=OFF
    -DBGFX_OPENGLES_VERSION=30
    "-DBGFX_ADDITIONAL_TOOL_PATHS=${CURRENT_INSTALLED_DIR}/../${HOST_TRIPLET}/tools/bgfx"
    ${FEATURE_OPTIONS}
  OPTIONS_DEBUG
    -DBGFX_BUILD_TOOLS=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/${PORT}")
vcpkg_copy_pdbs()

if ("tools" IN_LIST FEATURES)
  vcpkg_copy_tools(TOOL_NAMES bin2c shaderc geometryc texturec AUTO_CLEAN)
endif ()

vcpkg_install_copyright(
  FILE_LIST "${CURRENT_PACKAGES_DIR}/share/licences/${PORT}/LICENSE"
  COMMENT [[
bgfx includes third-party components which are subject to specific license
terms. Check the sources for details.
]])

file(REMOVE_RECURSE
  "${CURRENT_PACKAGES_DIR}/share/licences"
  "${CURRENT_PACKAGES_DIR}/debug/include"
  "${CURRENT_PACKAGES_DIR}/debug/share"
)
