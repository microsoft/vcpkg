include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO IntelRealSense/librealsense
    REF v2.10.0
    SHA512 b00cd4617d59197f7baa40d5a4833027c2b0c45e3e67047dce38e9415905ecf78c1ee9fe499c8e3292b54b8de8e96064001d0f154fdb10b2c64c19a8162db6d1
    HEAD_REF master
)

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES
        ${CMAKE_CURRENT_LIST_DIR}/crt-linkage-restriction.patch
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" BUILD_SHARED)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DENFORCE_METADATA=ON
        -DBUILD_EXAMPLES=OFF
        -DBUILD_GRAPHICAL_EXAMPLES=OFF
        -DBUILD_PYTHON_BINDINGS=OFF
        -DBUILD_UNIT_TESTS=OFF
        -DBUILD_WITH_OPENMP=OFF  # keep OpenMP off until librealsense issue #744 is patched
        -DBUILD_SHARED_LIBS=${BUILD_SHARED}
    OPTIONS_DEBUG
        "-DCMAKE_PDB_OUTPUT_DIRECTORY=${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg"
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/realsense2)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
# Handle copyright
file(COPY ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/realsense2)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/realsense2/COPYING ${CURRENT_PACKAGES_DIR}/share/realsense2/copyright)

vcpkg_copy_pdbs()

