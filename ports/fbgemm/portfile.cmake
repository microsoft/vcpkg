# The project's CMakeLists.txt uses Python to select source files. Check if it is available in advance.
vcpkg_find_acquire_program(PYTHON3)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO pytorch/fbgemm
    REF "v${VERSION}"
    SHA512 dde37e9fd89817c77ea13bb81de73a1aec0318b480ab53e82df5cddc8bc95a9a8ba52462452bbffb07cc8c2374c68d75adcb71b8e68f27952c6b32ccab81ff61
    PATCHES
        fix-cmakelists.patch
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    set(FBGEMM_LIB_TYPE STATIC)
else()
    set(FBGEMM_LIB_TYPE SHARED)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DFBGEMM_BUILD_TESTS=OFF
        -DFBGEMM_BUILD_BENCHMARKS=OFF
        -DFBGEMM_LIBRARY_TYPE=${FBGEMM_LIB_TYPE}
        -DPython_EXECUTABLE=${PYTHON3}
)
vcpkg_cmake_install()
vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(PACKAGE_NAME fbgemmLibrary CONFIG_PATH share/cmake/fbgemm)

file(RENAME
    "${CURRENT_PACKAGES_DIR}/share/fbgemmLibrary/fbgemmLibraryConfig.cmake"
    "${CURRENT_PACKAGES_DIR}/share/fbgemmLibrary/fbgemmLibraryTargets.cmake")
file(WRITE "${CURRENT_PACKAGES_DIR}/share/fbgemmLibrary/fbgemmLibraryConfig.cmake"
    "include(CMakeFindDependencyMacro)\n"
    "find_dependency(asmjit CONFIG)\n"
    "find_dependency(cpuinfo CONFIG)\n"
    "include(\"\${CMAKE_CURRENT_LIST_DIR}/fbgemmLibraryTargets.cmake\")\n")

# this internal header is required by pytorch
file(INSTALL     "${SOURCE_PATH}/src/RefImplementations.h"
     DESTINATION "${CURRENT_PACKAGES_DIR}/include/fbgemm/src")
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME "copyright")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
