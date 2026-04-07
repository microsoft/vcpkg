vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO AcademySoftwareFoundation/openvdb
    REF "v${VERSION}"
    SHA512 67b859bf77c53e68116faa7915bb6a5a50a8cff10435762890e13348625e8aebdb6661b722017632471648afe31e2f9d4cd2e18456c728192bfd0accd70a40ef
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
        "nanovdb-tools" NANOVDB_BUILD_TOOLS
)

if (OPENVDB_BUILD_NANOVDB)
    set(NANOVDB_OPTIONS
    -DNANOVDB_USE_INTRINSICS=ON
    -DNANOVDB_USE_CUDA=ON
    -DNANOVDB_CUDA_KEEP_PTX=ON
    -DNANOVDB_USE_OPENVDB=ON
    )
    vcpkg_find_cuda(OUT_CUDA_TOOLKIT_ROOT cuda_toolkit_root)
    list(APPEND FEATURE_OPTIONS
        "-DCMAKE_CUDA_COMPILER=${NVCC}"
        "-DCUDAToolkit_ROOT=${cuda_toolkit_root}"
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
        NANOVDB_BUILD_TOOLS
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/OpenVDB)

vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")

if (OPENVDB_BUILD_TOOLS)
    vcpkg_copy_tools(TOOL_NAMES vdb_print vdb_render vdb_view vdb_lod AUTO_CLEAN)
endif()

if (NANOVDB_BUILD_TOOLS)
    vcpkg_copy_tools(TOOL_NAMES nanovdb_convert nanovdb_print nanovdb_validate AUTO_CLEAN)
endif()

configure_file("${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake.in" "${CURRENT_PACKAGES_DIR}/share/${PORT}/vcpkg-cmake-wrapper.cmake" @ONLY)
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
