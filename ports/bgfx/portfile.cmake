vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/bkaradzic/bgfx.cmake/archive/refs/tags/v1.118.8384-362.tar.gz"
    FILENAME "v1.118.8384-362.tar.gz"
    SHA512 56203c40a724cd9e225d1c3142a30f8dd2e2f8cfc869a19cfa512bc69f0f62cd9460d016f1345a21bae9ef81323571d30dc588fde53f0fd0ba8628f7bbbab563
)

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH_BX
  REPO "bkaradzic/bx"
  HEAD_REF master
  REF aed1086c48884b1b4f1c2f9af34c5198624263f6
  SHA512 63bc5c6358f6a760bd5d8d056ef6fc6de175dcf8b940d5490225f13dfdd791c6b1d6bd2087d5d48a34955649bc12cbcc92f5221188ba0df5eb5c5d00eb389e94
)

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH_BIMG
  REPO "bkaradzic/bimg"
  HEAD_REF master
  REF 85109d7cdbe775a0ab72cf38510df525d5e8d3da
  SHA512 b3e082cd249e802e6d209ed45a552843604713a06597277b2855d1fa1c39b3d5136d5589599a85126eda218ccfee0ce6177f004cb5dccb912fe64ea7e07af2a8
  PATCHES fix-headerfile.patch
)

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH_BGFX
  REPO "bkaradzic/bgfx"
  HEAD_REF master
  REF 66de825e6f9de21890b336994141ab5dbc214dec
  SHA512 16ee1d3897dce5fcee7e658f793e078a1f3547b5d3512ebb860819d5105df99f87e4389ee1c66c1d24df04e0e589b6842cf36a52581e21732164017098f36f60
)

vcpkg_check_features(
  OUT_FEATURE_OPTIONS FEATURE_OPTIONS
  FEATURES tools BGFX_BUILD_TOOLS multithreaded BGFX_CONFIG_MULTITHREADED
)

if (BGFX_BUILD_TOOLS AND TARGET_TRIPLET MATCHES "(windows|uwp)")
  # bgfx doesn't apply __declspec(dllexport) which prevents dynamic linking for tools
  set(BGFX_LIBRARY_TYPE "STATIC")
elseif (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
  set(BGFX_LIBRARY_TYPE "SHARED")
else ()
  set(BGFX_LIBRARY_TYPE "STATIC")
endif ()

vcpkg_extract_source_archive(SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    PATCHES fix-dependencies.patch
)

vcpkg_cmake_configure(
  SOURCE_PATH "${SOURCE_PATH}"
  OPTIONS -DBX_DIR=${SOURCE_PATH_BX}
          -DBIMG_DIR=${SOURCE_PATH_BIMG}
          -DBGFX_DIR=${SOURCE_PATH_BGFX}
          -DBGFX_LIBRARY_TYPE=${BGFX_LIBRARY_TYPE}
          -DBX_AMALGAMATED=ON
          -DBGFX_AMALGAMATED=ON
          -DBGFX_BUILD_EXAMPLES=OFF
          -DBGFX_OPENGLES_VERSION=30
          ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/${PORT}")
vcpkg_copy_pdbs()

if (BGFX_BUILD_TOOLS)
  vcpkg_copy_tools(
    TOOL_NAMES shaderc geometryc geometryv texturec texturev AUTO_CLEAN
  )
endif ()

# Handle copyright
file(
  INSTALL "${CURRENT_PACKAGES_DIR}/share/licences/${PORT}/LICENSE"
  DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
  RENAME copyright
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/licences"
     "${CURRENT_PACKAGES_DIR}/debug/include"
     "${CURRENT_PACKAGES_DIR}/debug/share"
)
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static" OR NOT VCPKG_TARGET_IS_WINDOWS)
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()
