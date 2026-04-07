vcpkg_buildpath_length_warning(37)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO alembic/alembic
    REF "${VERSION}"
    SHA512 f2b5c8158b1d43b73bcc1d64e83f299ae42e922b5ee25b61b02acb6cbf58b1ffc57e53485e0ebe736ff1f5a909b5f59e6faa8c639a89662c39b029dda3206619
    HEAD_REF master
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
