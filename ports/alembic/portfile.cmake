vcpkg_buildpath_length_warning(37)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO alembic/alembic
    REF "${VERSION}"
    SHA512 89a480970eb09893112bf650011ede852205d1fa3718680a3983392bbcf3eb3f22f4ec01f42d12bfcaf655ce43d7d6f583b764ec03f4c5a84023359502b3636e
    HEAD_REF master
    PATCHES
        fix-runtime-destination.patch
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" ALEMBIC_SHARED_LIBS)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        hdf5 USE_HDF5
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DALEMBIC_SHARED_LIBS=${ALEMBIC_SHARED_LIBS}
        -DUSE_TESTS=OFF
        ${FEATURE_OPTIONS}
        -DALEMBIC_DEBUG_WARNINGS_AS_ERRORS=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/Alembic)

vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

set(TOOLS abcdiff abcecho abcechobounds abcls abcstitcher abctree)
if(USE_HDF5)
    list(APPEND TOOLS abcconvert)
endif()

vcpkg_copy_tools(
    TOOL_NAMES ${TOOLS}
    AUTO_CLEAN
)
vcpkg_copy_tool_dependencies("${CURRENT_PACKAGES_DIR}/tools/${PORT}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
