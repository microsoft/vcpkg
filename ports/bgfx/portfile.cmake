if(VCPKG_TARGET_IS_WINDOWS)
  vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_download_distfile(
  ARCHIVE_FILE
  URLS https://github.com/bkaradzic/bgfx.cmake/releases/download/v${VERSION}/bgfx.cmake.v${VERSION}.tar.gz
  FILENAME bgfx.cmake.v${VERSION}.tar.gz
  SHA512 889ccc4657415e55cc891ad04ba2b42acaf46e664fd9ed8c6bedebb0f43ba7f2b75a9ad54387d02cf88a6accc7221f7cd5cc74a7dc8248b668ecf14f525f53c8
)

vcpkg_extract_source_archive(
  SOURCE_PATH
  ARCHIVE "${ARCHIVE_FILE}"
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
    -DBX_AMALGAMATED=ON
    -DBGFX_AMALGAMATED=ON
    -DBGFX_BUILD_EXAMPLES=OFF
    -DBGFX_OPENGLES_VERSION=30
    "-DBGFX_CMAKE_USER_SCRIPT=${CURRENT_PORT_DIR}/vcpkg-inject-packages.cmake"
    "-DBGFX_ADDITIONAL_TOOL_PATHS=${CURRENT_INSTALLED_DIR}/../${HOST_TRIPLET}/tools/bgfx"
    ${FEATURE_OPTIONS}
  OPTIONS_DEBUG
    -DBGFX_BUILD_TOOLS=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/${PORT}")
vcpkg_copy_pdbs()

if ("tools" IN_LIST FEATURES)
  vcpkg_copy_tools(TOOL_NAMES bin2c shaderc geometryc geometryv texturec texturev AUTO_CLEAN)
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
