include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO AcademySoftwareFoundation/openvdb
    REF v6.1.0
    SHA512 99ebbb50104ef87792ab73989e8714c4f283fb02d04c3033126b5f0d927ff7bbdebe35c8214ded841692941d8ed8ae551fd6d1bf90ad7dc07bedc3b38b9c4b38
    HEAD_REF master
    PATCHES
        0001-remove-pkgconfig.patch
        0002-fix-cmake-modules.patch
        0003-fix-cmake.patch
)

if (VCPKG_LIBRARY_LINKAGE STREQUAL static)
    set(OPENVDB_STATIC ON)
    set(OPENVDB_SHARED OFF)
else()
    set(OPENVDB_STATIC OFF)
    set(OPENVDB_SHARED ON)
endif()

if ("tools" IN_LIST FEATURES)
  if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    set(OPENVDB_BUILD_TOOLS ON)
  else()
    message(ERROR "Unable to build tools if static libraries are required")
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
        #-DOPENVDB_BUILD_VDB_RENDER=${OPENVDB_BUILD_TOOLS} # Enable vdb_render when https://github.com/openexr/openexr/issues/302 is fixed
        -DOPENVDB_BUILD_VDB_LOD=${OPENVDB_BUILD_TOOLS}
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/OpenVDB TARGET_PATH share/openvdb)

vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include ${CURRENT_PACKAGES_DIR}/debug/share)

if (OPENVDB_BUILD_TOOLS)
    # copy tools to tools/openvdb directory
    file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/tools/${PORT}/)
    file(RENAME ${CURRENT_PACKAGES_DIR}/bin/vdb_print.exe ${CURRENT_PACKAGES_DIR}/tools/${PORT}/vdb_print.exe)
    #file(RENAME ${CURRENT_PACKAGES_DIR}/bin/vdb_render.exe ${CURRENT_PACKAGES_DIR}/tools/${PORT}/vdb_render.exe)
    #file(RENAME ${CURRENT_PACKAGES_DIR}/bin/vdb_view.exe ${CURRENT_PACKAGES_DIR}/tools/${PORT}/vdb_view.exe) # vdb_view does not support win32 currently.
    file(RENAME ${CURRENT_PACKAGES_DIR}/bin/vdb_lod.exe ${CURRENT_PACKAGES_DIR}/tools/${PORT}/vdb_lod.exe)
    vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/${PORT})

    # remove debug versions of tools
    file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/bin/vdb_print.exe)
    #file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/bin/vdb_render.exe)
    #file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/bin/vdb_view.exe) # vdb_view does not support win32 currently.
    file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/bin/vdb_lod.exe)
endif()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/openvdb/COPYRIGHT DESTINATION ${CURRENT_PACKAGES_DIR}/share/openvdb RENAME copyright)
