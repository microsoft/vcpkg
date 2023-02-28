vcpkg_download_distfile(ARCHIVE
  URLS "https://github.com/bkaradzic/bgfx.cmake/archive/refs/tags/v1.118.8415-411.tar.gz"
  FILENAME "bgfx.cmake.tar.gz"
  SHA512 7a956a2d08e0e5b26b1a91931966234761f8dc6f9475b4b3fb4bb0045c0cf38f237bc34c4f74ca21f273b36367f3ffd0c17d379687e947bc9e4b779faf269cd4
)

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH_BX
  REPO "bkaradzic/bx"
  HEAD_REF master
  REF fa1411e4aa111c8b004c97660ab31ba1a5287835
  SHA512 0c6bd7e41c6dd3263c01d761aefdd55d2ed527ca694b52f563c6ded3ba5569df1492c8d04e5f76de3b1bdf7c5ca2978b8ec394d48ea29593535979f204d3ad0c
)

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH_BIMG
  REPO "bkaradzic/bimg"
  HEAD_REF master
  REF 7afa2419254fd466c013a51bdeb0bee3022619c4
  SHA512 514deed00f8bc4106f67b777dca72d0ed0accb1ae057ad37d22a21c83ad3a85ad23d220ac0cf40b6a8006d43c308b1acfad464b51e64075aa01598731a1557df
)

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH_BGFX
  REPO "bkaradzic/bgfx"
  HEAD_REF master
  REF bea82a13436a42a339e26354c8106dc28dedc178
  SHA512 2a758891b362ee6d22e1ec1038075fb9e7f19911868f182aa3f2264150cffe1795a87fc959c566b89400f0c2fe4277d5dba8beb4e7c7e1374644b91ad7979b73
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
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/vcpkg-inject-packages.cmake" DESTINATION "${SOURCE_PATH}")

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
          -DBGFX_CMAKE_USER_SCRIPT=vcpkg-inject-packages.cmake
          ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/${PORT}")
vcpkg_copy_pdbs()

if (BGFX_BUILD_TOOLS)
  vcpkg_copy_tools(
    TOOL_NAMES bin2c shaderc geometryc geometryv texturec texturev AUTO_CLEAN
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
