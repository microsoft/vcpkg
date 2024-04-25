vcpkg_buildpath_length_warning(37)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO alembic/alembic
    REF "${VERSION}"
    SHA512 6371b830242be90d4ea833248df5fd42d9e713e305d15eb1383d04410319acdae5743d48d65e8f75f1cedce777d2af7d969cde095f678b17322c19f1c69f477b
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
