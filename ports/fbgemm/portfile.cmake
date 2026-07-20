# The project's CMakeLists.txt uses Python to select source files. Check if it is available in advance.
vcpkg_find_acquire_program(PYTHON3)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO pytorch/fbgemm
    REF "v${VERSION}"
    SHA512 d8f5963bc118aad2c38e41eac18b0ef5c8973a01fa24cb376a39d666ab4d08518650fd5f1bda3f4968b539d195f307dea6920304bec616f73739ab26b0a5e51f
    PATCHES
        fix-cmakelists.patch
        linkage.patch
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
