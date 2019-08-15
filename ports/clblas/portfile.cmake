include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO clMathLibraries/clBLAS
    REF v2.12
    SHA512 5d9b0c58adde69e83d95e9c713e0cdc5f64785fe7e05553a14c57fa483c4ef39e9dc780c26880a7f15924967d5ce4ea29035c29d63eac7ee5a2ae5ddacac2b72
    HEAD_REF master
)

# v2.12 has a very old FindOpenCL.cmake using OPENCL_ vs. OpenCL_ var names
# conflicting with the built-in, more modern FindOpenCL.cmake
file(
    REMOVE ${SOURCE_PATH}/src/FindOpenCL.cmake
)

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES ${CMAKE_CURRENT_LIST_DIR}/cmake.patch
)

vcpkg_find_acquire_program(PYTHON3)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}/src
    PREFER_NINJA
    OPTIONS
        -DBUILD_TEST=OFF
        -DBUILD_KTEST=OFF
        -DSUFFIX_LIB=
        -DPYTHON_EXECUTABLE=${PYTHON3}
)

vcpkg_install_cmake()
if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(INSTALL
        "${SOURCE_PATH}/LICENSE"
    DESTINATION
        ${CURRENT_PACKAGES_DIR}/share/clblas
    RENAME copyright
)

file(REMOVE
        ${CURRENT_PACKAGES_DIR}/debug/bin/clBLAS-tune.pdb
        ${CURRENT_PACKAGES_DIR}/debug/bin/clBLAS-tune.exe
        ${CURRENT_PACKAGES_DIR}/bin/clBLAS-tune.exe
        ${CURRENT_PACKAGES_DIR}/debug/bin/concrt140d.dll
        ${CURRENT_PACKAGES_DIR}/debug/bin/msvcp140d.dll
        ${CURRENT_PACKAGES_DIR}/debug/bin/vcruntime140d.dll
)

vcpkg_fixup_cmake_targets(CONFIG_PATH CMake)

vcpkg_copy_pdbs()
