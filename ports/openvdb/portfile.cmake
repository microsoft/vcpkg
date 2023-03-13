vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO AcademySoftwareFoundation/openvdb
    REF be0e7a78861d2b7d9643f7a0cab04f3ab5951686 # v10.0.0
    SHA512 92301bf675d700fedb0a2b3c4653158eeda6105e70623e5e4bda15d73391427cf0295a0426204888e2fe062847025542717bff34ceb923e51cffa1721e9d4105
    PATCHES
        0003-fix-cmake.patch
)

file(REMOVE "${SOURCE_PATH}/cmake/FindTBB.cmake")
file(REMOVE "${SOURCE_PATH}/cmake/FindIlmBase.cmake")
file(REMOVE "${SOURCE_PATH}/cmake/FindBlosc.cmake")
file(REMOVE "${SOURCE_PATH}/cmake/FindOpenEXR.cmake")

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" OPENVDB_STATIC)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" OPENVDB_SHARED)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        "tools" OPENVDB_BUILD_TOOLS
)


if ("ax" IN_LIST FEATURES)
  if(NOT VCPKG_TARGET_IS_WINDOWS)
    set(OPENVDB_BUILD_AX ON)
  else()
    message(FATAL_ERROR "Currently no support for building OpenVDB AX on Windows.")  
  endif()
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DOPENVDB_BUILD_UNITTESTS=OFF
        -DOPENVDB_BUILD_PYTHON_MODULE=OFF
        -DOPENVDB_ENABLE_3_ABI_COMPATIBLE=OFF
        -DUSE_EXR=ON
        -DUSE_GLFW3=ON
        -DUSE_IMATH_HALF=ON
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

if (OPENVDB_BUILD_TOOLS)
    vcpkg_copy_tools(TOOL_NAMES vdb_print vdb_render vdb_view vdb_lod AUTO_CLEAN)
endif()

configure_file("${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake.in" "${CURRENT_PACKAGES_DIR}/share/${PORT}/vcpkg-cmake-wrapper.cmake" @ONLY)
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(INSTALL "${SOURCE_PATH}/openvdb/openvdb/COPYRIGHT" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
