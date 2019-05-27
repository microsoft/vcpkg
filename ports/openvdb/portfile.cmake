include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO AcademySoftwareFoundation/openvdb
    REF v6.0.0
    SHA512 6b9e267fff46647b39e1e6faa12059442196c1858df1fda1515cfc375e25bc3033e2828c80e63a652509cfba386376e022cebf81ec85aaccece421b0c721529b
    HEAD_REF master
    PATCHES
        0001-fix-cmake-modules.patch
        0002-add-custom-options.patch
        0003-build-only-necessary-targets.patch
        0004-add-necessary-head.patch
        blosc.patch
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
        -DOPENVDB_STATIC=${OPENVDB_STATIC}
        -DOPENVDB_SHARED=${OPENVDB_SHARED}
        -DOPENVDB_BUILD_TOOLS=${OPENVDB_BUILD_TOOLS}
)

vcpkg_install_cmake()

vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

if (OPENVDB_BUILD_TOOLS)
    # copy tools to tools/openvdb directory
    file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/tools/${PORT}/)
    file(RENAME ${CURRENT_PACKAGES_DIR}/bin/vdb_print.exe ${CURRENT_PACKAGES_DIR}/tools/${PORT}/vdb_print.exe)
    file(RENAME ${CURRENT_PACKAGES_DIR}/bin/vdb_render.exe ${CURRENT_PACKAGES_DIR}/tools/${PORT}/vdb_render.exe)
    file(RENAME ${CURRENT_PACKAGES_DIR}/bin/vdb_view.exe ${CURRENT_PACKAGES_DIR}/tools/${PORT}/vdb_view.exe)
    vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/${PORT})

    # remove debug versions of tools
    file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/bin/vdb_render.exe)
    file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/bin/vdb_print.exe)
    file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/bin/vdb_view.exe)
endif()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/openvdb/COPYRIGHT DESTINATION ${CURRENT_PACKAGES_DIR}/share/openvdb RENAME copyright)
