vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO "bkaradzic/bgfx.cmake"
  HEAD_REF master
  REF v${VERSION}
  SHA512 5d19e3ba50db25c203d87b1f47e9151a21f2afced35a7306d33c4fd2fc44f4d56826a1920023bd6de5cebbed2301e39e152f4c17e63905e34f56b39e34b235d1
)

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH_BX
  REPO "bkaradzic/bx"
  HEAD_REF master
  REF 9b1805ea8bdc63552e4e32ff72842fce0238bb10
  SHA512 9032b160204faf939b33d46123b7220de441377b2fc95447b87714ce12d31f0c220ee9b53d9a7807f8ae3e807f7d2bea6dd255a4443bb66e4aa0679f10696e96
)

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH_BIMG
  REPO "bkaradzic/bimg"
  HEAD_REF master
  REF ec02df824a763b2e2ae31e19c674ba0bc88c0695
  SHA512 e0f26afae510244e85758ddaada83e3d6b48745b447e197bffcb972f1fd8f42269f2e9f3ee48a6d54ea99d0ad66062a6212a3604f7e61d616681b815fb8a6d8f
)

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH_BGFX
  REPO "bkaradzic/bgfx"
  HEAD_REF master
  REF e2c5b1d3e1320145baebc405a3c894cd851f8dc1
  SHA512 5bde6c2b4f147c01c7949eff529b940b8981e06a3b72e8389e991b98e3052a83762e59a798b1b0eb3292c35889f8f3fb68f54613c270c4f3f0f942e11cc9f3e9
)

vcpkg_check_features(
  OUT_FEATURE_OPTIONS FEATURE_OPTIONS
  FEATURES tools BGFX_BUILD_TOOLS multithreaded BGFX_CONFIG_MULTITHREADED
)

if (TARGET_TRIPLET MATCHES "(windows|uwp)")
  # bgfx doesn't apply __declspec(dllexport) which prevents dynamic linking
  set(BGFX_LIBRARY_TYPE "STATIC")
elseif (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
  set(BGFX_LIBRARY_TYPE "SHARED")
else ()
  set(BGFX_LIBRARY_TYPE "STATIC")
endif ()

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
