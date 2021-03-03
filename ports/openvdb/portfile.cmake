vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO AcademySoftwareFoundation/openvdb
    REF 7991ec6672401a8cf04fbe1500db0eb467ae46ea # v8.0.1
    SHA512 a4fb95162fcb0e37ae07f8b6740da9533016b8e25fc478f87dcbdbe574b01ab231371788958e51648af32f693b844e293d29399b8a75dfd0976b9073a8914902
    HEAD_REF master
    PATCHES
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

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
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
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/OpenVDB TARGET_PATH share/openvdb)

vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include ${CURRENT_PACKAGES_DIR}/debug/share)

if (OPENVDB_BUILD_TOOLS)
    vcpkg_copy_tools(TOOL_NAMES vdb_print vdb_render vdb_view vdb_lod AUTO_CLEAN)
endif()

configure_file(${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake.in ${CURRENT_PACKAGES_DIR}/share/${PORT}/vcpkg-cmake-wrapper.cmake @ONLY)
file(INSTALL ${CMAKE_CURRENT_LIST_DIR}/usage DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
file(INSTALL ${SOURCE_PATH}/openvdb/COPYRIGHT DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
