vcpkg_download_distfile(
    ARCHIVE_FILE
    URLS https://github.com/bkaradzic/bgfx.cmake/releases/download/v${VERSION}/bgfx.cmake.v${VERSION}.tar.gz
    FILENAME bgfx.cmake.v${VERSION}.tar.gz
    SHA512 8aea4f3e548f8a79e8899c9d47ec3ca78dae48f77ae039d6f5df325ba73a8ddb70c9b7c1f0cb4129ac488b445e8a8523f36a964e509133bb4a449e073ebf6112
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE ${ARCHIVE_FILE}
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

# It's important to have `${CMAKE_CURRENT_LIST_DIR}` verbatim escaped in bgfxConfig.cmake
if (WIN32)
  set(BGFX_ADDITIONAL_TOOL_PATHS "\$\$\{CMAKE_CURRENT_LIST_DIR}/../../../${HOST_TRIPLET}/tools/bgfx \$\$\{CMAKE_CURRENT_LIST_DIR}/../../../bgfx_${HOST_TRIPLET}/tools/bgfx")
else()
  set(BGFX_ADDITIONAL_TOOL_PATHS "\"\\\$\$\{CMAKE_CURRENT_LIST_DIR}/../../../${HOST_TRIPLET}/tools/bgfx \\\$\$\{CMAKE_CURRENT_LIST_DIR}/../../../bgfx_${HOST_TRIPLET}/tools/bgfx\"")
endif()

vcpkg_cmake_configure(
  SOURCE_PATH "${SOURCE_PATH}"
  OPTIONS -DBGFX_LIBRARY_TYPE=${BGFX_LIBRARY_TYPE}
          -DBX_AMALGAMATED=ON
          -DBGFX_AMALGAMATED=ON
          -DBGFX_BUILD_EXAMPLES=OFF
          -DBGFX_OPENGLES_VERSION=30
          -DBGFX_CMAKE_USER_SCRIPT=vcpkg-inject-packages.cmake
          # #25529: Need to inject an extra path because VCPKG_HOST_TARGET is not determined automatically
          -DBGFX_ADDITIONAL_TOOL_PATHS=${BGFX_ADDITIONAL_TOOL_PATHS}
          ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/${PORT}")
vcpkg_copy_pdbs()

if ("tools" IN_LIST FEATURES)
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
