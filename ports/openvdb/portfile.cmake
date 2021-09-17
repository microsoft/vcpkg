vcpkg_download_distfile(TBB_PATCH
  URLS https://github.com/AcademySoftwareFoundation/openvdb/pull/1027.diff
  FILENAME openvdb-1027.patch
  SHA512 1e260f299fc861f7d61444c12a7115276d5242ebba936d86ce3f8cfd5b2eb95499c72a77da8c9f28e2f49e38479c677497c70bed3427dcccad082afa483e29da
)

set(FIXED_TBB_PATCH "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-openvdb-1027.patch")

# This adjustment is needed to make the patch apply cleanly against v8.1.0
file(READ "${TBB_PATCH}" tbb_patch_contents)
string(REPLACE "       run: cd build && ctest -V" "       run: ./ci/test.sh" tbb_patch_contents "${tbb_patch_contents}")
file(WRITE "${FIXED_TBB_PATCH}" "${tbb_patch_contents}")

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO AcademySoftwareFoundation/openvdb
  REF ea786c46b7a1b5158789293d9b148b379fc9914c # v8.1.0
  SHA512 3c4ab3db35b3eb019149ac455f0c7a262081e9866b7e49eaba05424bf837debccf0c987c2555d3c91a2cff2d1ba4b41862f544fd4684558f3a319616ef3c9eb3
  HEAD_REF master
  PATCHES
    "${FIXED_TBB_PATCH}"
    0003-fix-cmake.patch
)

file(REMOVE ${SOURCE_PATH}/cmake/FindTBB.cmake)
file(REMOVE ${SOURCE_PATH}/cmake/FindIlmBase.cmake)
file(REMOVE ${SOURCE_PATH}/cmake/FindBlosc.cmake)
file(REMOVE ${SOURCE_PATH}/cmake/FindOpenEXR.cmake)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" OPENVDB_STATIC)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" OPENVDB_SHARED)

set(OPENVDB_BUILD_TOOLS OFF)
if ("tools" IN_LIST FEATURES)
  if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    set(OPENVDB_BUILD_TOOLS ON)
  else()
    message(FATAL_ERROR "Unable to build tools if static libraries are required")
  endif()
endif()

if ("ax" IN_LIST FEATURES)
  if(NOT VCPKG_TARGET_IS_WINDOWS)
    set(OPENVDB_BUILD_AX ON)
  else()
    message(FATAL_ERROR "Currently no support for building OpenVDB AX on Windows.")  
  endif()
endif()

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DOPENVDB_BUILD_UNITTESTS=OFF
        -DOPENVDB_BUILD_PYTHON_MODULE=OFF
        -DOPENVDB_ENABLE_3_ABI_COMPATIBLE=OFF
        -DUSE_GLFW3=ON
        -DOPENVDB_CORE_STATIC=${OPENVDB_STATIC}
        -DOPENVDB_CORE_SHARED=${OPENVDB_SHARED}
        -DOPENVDB_BUILD_VDB_PRINT=${OPENVDB_BUILD_TOOLS}
        -DOPENVDB_BUILD_VDB_VIEW=${OPENVDB_BUILD_TOOLS}
        -DOPENVDB_BUILD_VDB_RENDER=${OPENVDB_BUILD_TOOLS}
        -DOPENVDB_BUILD_VDB_LOD=${OPENVDB_BUILD_TOOLS}
        -DUSE_PKGCONFIG=OFF
        ${OPENVDB_BUILD_AX}
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/OpenVDB)

vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_replace_string(${CURRENT_PACKAGES_DIR}/share/openvdb/FindOpenVDB.cmake "\${USE_BLOSC}" "ON")
vcpkg_replace_string(${CURRENT_PACKAGES_DIR}/share/openvdb/FindOpenVDB.cmake "\${USE_ZLIB}" "ON")
vcpkg_replace_string(${CURRENT_PACKAGES_DIR}/share/openvdb/FindOpenVDB.cmake "\${USE_LOG4CPLUS}" "OFF")
vcpkg_replace_string(${CURRENT_PACKAGES_DIR}/share/openvdb/FindOpenVDB.cmake "\${USE_IMATH_HALF}" "OFF")

if(OPENVDB_STATIC)
  vcpkg_replace_string(
    ${CURRENT_PACKAGES_DIR}/share/openvdb/FindOpenVDB.cmake
    "set(_OPENVDB_VISIBLE_DEPENDENCIES\n"
    "set(_OPENVDB_VISIBLE_DEPENDENCIES blosc ZLIB::ZLIB\n"
  )
endif()

if (OPENVDB_BUILD_TOOLS)
    vcpkg_copy_tools(TOOL_NAMES vdb_print vdb_render vdb_view vdb_lod AUTO_CLEAN)
endif()

configure_file("${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake.in" "${CURRENT_PACKAGES_DIR}/share/${PORT}/vcpkg-cmake-wrapper.cmake" @ONLY)
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(INSTALL "${SOURCE_PATH}/openvdb/openvdb/COPYRIGHT" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
