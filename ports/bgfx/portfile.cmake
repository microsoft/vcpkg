if(VCPKG_TARGET_IS_WINDOWS)
  vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_download_distfile(
  ARCHIVE_FILE
  URLS https://github.com/bkaradzic/bgfx.cmake/releases/download/v${VERSION}/bgfx.cmake.v${VERSION}.tar.gz
  FILENAME bgfx.cmake.v${VERSION}.tar.gz
  SHA512 afbe9dce1a977c209c7ca9c56bc77efafd63849c5d323ccf2c3ce7c91091e65dfd3aaebdf7e3f1e7be7563da0f041c9e4ffe226ff2b4364ffebe4952215abcc4
)

vcpkg_extract_source_archive(
  SOURCE_PATH
  ARCHIVE "${ARCHIVE_FILE}"
  PATCHES
    fix-dependencies.patch
)
# bimg's dependencies come from vcpkg through vcpkg-bgfx-deps.cmake. The shader toolchain
# (glslang, spirv-*, tint) stays vendored: tint builds against SPIRV-Tools internals.
# cgltf, dear-imgui, meshoptimizer and bgfx's stb only serve the viewers and examples, which are not built.
file(REMOVE_RECURSE
  "${SOURCE_PATH}/bgfx/3rdparty/cgltf"
  "${SOURCE_PATH}/bgfx/3rdparty/dear-imgui"
  "${SOURCE_PATH}/bgfx/3rdparty/meshoptimizer"
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
    # Also drop texturev and geometryv, which need bgfx's modified dear-imgui
    -DBGFX_BUILD_TOOLS_GEOMETRY=OFF
    -DBGFX_BUILD_TOOLS_TEXTURE=OFF
    -DBGFX_OPENGLES_VERSION=30
    "-DBGFX_ADDITIONAL_TOOL_PATHS=${CURRENT_INSTALLED_DIR}/../${HOST_TRIPLET}/tools/bgfx"
    "-DBGFX_CMAKE_USER_SCRIPT=${CMAKE_CURRENT_LIST_DIR}/vcpkg-bgfx-deps.cmake"
    ${FEATURE_OPTIONS}
  OPTIONS_DEBUG
    -DBGFX_BUILD_TOOLS=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/${PORT}")
vcpkg_copy_pdbs()

if ("tools" IN_LIST FEATURES)
  # shaderc loads the prebuilt DXIL compiler from its own directory at runtime
  file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools/${PORT}")
  foreach(dxc IN ITEMS libdxcompiler.so dxcompiler.dll)
    if(EXISTS "${CURRENT_PACKAGES_DIR}/bin/${dxc}")
      file(RENAME "${CURRENT_PACKAGES_DIR}/bin/${dxc}" "${CURRENT_PACKAGES_DIR}/tools/${PORT}/${dxc}")
    endif()
  endforeach()
  vcpkg_copy_tools(TOOL_NAMES bin2c shaderc AUTO_CLEAN)
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
