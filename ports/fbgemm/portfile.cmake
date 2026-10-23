# The project's CMakeLists.txt uses Python to select source files. Check if it is available in advance.
vcpkg_find_acquire_program(PYTHON3)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO pytorch/fbgemm
    REF "v${VERSION}"
    SHA512 9bfa7ceac02604723085805d66e01df2cb2cfccde4830ed0ff822d0add78f71d75aa19365d86212c841a428be73922b0f027cab9ca2942847e96ae9ef3f25771
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

# OpenMP is not available with every compiler, only require it when the targets reference it.
file(READ "${CURRENT_PACKAGES_DIR}/share/fbgemmLibrary/fbgemmLibraryTargets.cmake" FBGEMM_TARGETS)
if(FBGEMM_TARGETS MATCHES "OpenMP::OpenMP_CXX")
    set(FBGEMM_OPENMP_DEPENDENCY "find_dependency(OpenMP)\n")
endif()

file(WRITE "${CURRENT_PACKAGES_DIR}/share/fbgemmLibrary/fbgemmLibraryConfig.cmake"
    "include(CMakeFindDependencyMacro)\n"
    "${FBGEMM_OPENMP_DEPENDENCY}"
    "find_dependency(asmjit CONFIG)\n"
    "find_dependency(cpuinfo CONFIG)\n"
    "include(\"\${CMAKE_CURRENT_LIST_DIR}/fbgemmLibraryTargets.cmake\")\n")

# static consumers must not see the dllimport declarations
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    vcpkg_replace_string(
        "${CURRENT_PACKAGES_DIR}/include/fbgemm/FbgemmBuild.h"
        "#pragma once"
        "#pragma once\n\n#define FBGEMM_STATIC"
    )
endif()

# this internal header is required by pytorch
file(INSTALL     "${SOURCE_PATH}/src/RefImplementations.h"
     DESTINATION "${CURRENT_PACKAGES_DIR}/include/fbgemm/src")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
