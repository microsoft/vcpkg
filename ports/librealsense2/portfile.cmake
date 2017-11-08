include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO IntelRealSense/librealsense
    REF v2.8.1
    SHA512 af6ae166ef0879d4da434cebea95358a4c3907bd71913577008a21717a9e45400a6eafffe5ddbf9cc50bd939d4dae0863e2f34b7ee76de276fedc68117a21e71
    HEAD_REF master
)

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES
        ${CMAKE_CURRENT_LIST_DIR}/crt-linkage-restriction.patch
)

if(${VCPKG_LIBRARY_LINKAGE} STREQUAL static)
    set(BUILD_SHARED off)
else()
    set(BUILD_SHARED on)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DENFORCE_METADATA=on
        -DBUILD_EXAMPLES=off
        -DBUILD_GRAPHICAL_EXAMPLES=off
        -DBUILD_PYTHON_BINDINGS=off
        -DBUILD_UNIT_TESTS=off
        -DBUILD_WITH_OPENMP=off  # keep OpenMP off until librealsense issue #744 is patched
        -DBUILD_SHARED_LIBS=${BUILD_SHARED}
    OPTIONS_DEBUG
        "-DCMAKE_PDB_OUTPUT_DIRECTORY=${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg"
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/realsense2)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
# Handle copyright
file(COPY ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/librealsense2)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/librealsense2/COPYING ${CURRENT_PACKAGES_DIR}/share/librealsense2/copyright)

vcpkg_copy_pdbs()

