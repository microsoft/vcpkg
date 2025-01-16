vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO AcademySoftwareFoundation/openvdb
    REF "v${VERSION}"
    SHA512 7ea2997afa99ed1ed23422eb8b8420c7127c913432f94043ccf559b6720bba2f6e19376e955d8d9055ab765a821749936966f6e5925b9d36febaa724d866b90a
    PATCHES
        fix_cmake.patch
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
        "ax"    OPENVDB_BUILD_AX
        "nanovdb" OPENVDB_BUILD_NANOVDB
)

if (OPENVDB_BUILD_NANOVDB)
    set(NANOVDB_OPTIONS
    -DNANOVDB_BUILD_TOOLS=OFF
    -DNANOVDB_USE_INTRINSICS=ON
    -DNANOVDB_USE_CUDA=ON
    -DNANOVDB_CUDA_KEEP_PTX=ON
    -DNANOVDB_USE_OPENVDB=ON
)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DOPENVDB_BUILD_UNITTESTS=OFF
        -DOPENVDB_BUILD_PYTHON_MODULE=OFF
        -DOPENVDB_3_ABI_COMPATIBLE=OFF
        -DUSE_EXR=ON
        -DUSE_IMATH_HALF=ON
        -DOPENVDB_CORE_STATIC=${OPENVDB_STATIC}
        -DOPENVDB_CORE_SHARED=${OPENVDB_SHARED}
        -DOPENVDB_BUILD_VDB_PRINT=${OPENVDB_BUILD_TOOLS}
        -DOPENVDB_BUILD_VDB_VIEW=${OPENVDB_BUILD_TOOLS}
        -DOPENVDB_BUILD_VDB_RENDER=${OPENVDB_BUILD_TOOLS}
        -DOPENVDB_BUILD_VDB_LOD=${OPENVDB_BUILD_TOOLS}
        -DUSE_PKGCONFIG=OFF
        ${FEATURE_OPTIONS}
        -DUSE_EXPLICIT_INSTANTIATION=OFF
        ${NANOVDB_OPTIONS}
    MAYBE_UNUSED_VARIABLES
        OPENVDB_3_ABI_COMPATIBLE
        OPENVDB_BUILD_TOOLS
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
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/openvdb/openvdb/COPYRIGHT")
