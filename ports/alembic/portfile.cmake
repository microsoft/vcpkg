vcpkg_fail_port_install(ON_ARCH "x86") # see https://github.com/alembic/alembic/issues/372

vcpkg_buildpath_length_warning(37)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO alembic/alembic
    REF 1.8.3
    SHA512 0049c72d93e66e12d704d27e7ba36cd9c718667f2ce4f7baa1bee1613ed88ba53abea98f457e14f7f2144cb353810a4108d26c7dd1a1543ec2af576272f19036
    HEAD_REF master
    PATCHES
        disable-warnings-as-error.patch
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
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/Alembic)

vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

if(VCPKG_TARGET_IS_WINDOWS AND ALEMBIC_SHARED_LIBS)
    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
        file(RENAME "${CURRENT_PACKAGES_DIR}/lib/Alembic.dll" "${CURRENT_PACKAGES_DIR}/bin/Alembic.dll")
        vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/${PORT}/AlembicTargets-release.cmake" "\${_IMPORT_PREFIX}/lib/Alembic.dll" "\${_IMPORT_PREFIX}/bin/Alembic.dll")
    endif()
    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
        file(RENAME "${CURRENT_PACKAGES_DIR}/debug/lib/Alembic.dll" "${CURRENT_PACKAGES_DIR}/debug/bin/Alembic.dll")
        vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/${PORT}/AlembicTargets-debug.cmake" "\${_IMPORT_PREFIX}/debug/lib/Alembic.dll" "\${_IMPORT_PREFIX}/debug/bin/Alembic.dll")
    endif()
endif()

set(TOOLS abcdiff abcecho abcechobounds abcls abcstitcher abctree)
if(USE_HDF5)
    list(APPEND TOOLS abcconvert)
endif()

vcpkg_copy_tools(
    TOOL_NAMES ${TOOLS}
    AUTO_CLEAN
)
vcpkg_copy_tool_dependencies("${CURRENT_PACKAGES_DIR}/tools/${PORT}")

file(INSTALL "${SOURCE_PATH}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
