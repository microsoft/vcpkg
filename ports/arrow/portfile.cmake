include(vcpkg_common_functions)

if(NOT VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
  message(FATAL_ERROR "Apache Arrow only supports x64")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO apache/arrow
    REF apache-arrow-0.14.1
    SHA512 f5493a62becaaee9d26e05f33509f51c98e96a5efd5d5bbdffdf70456c254b62075f1c9bc63d1119289a22d00359dfe9862078a284f8e063ecf13bd338a50728
    HEAD_REF master
    PATCHES
        all.patch
        fix-msvc-1900.patch
)

string(COMPARE EQUAL ${VCPKG_LIBRARY_LINKAGE} "dynamic" ARROW_BUILD_SHARED)
string(COMPARE EQUAL ${VCPKG_LIBRARY_LINKAGE} "static" ARROW_BUILD_STATIC)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}/cpp
    PREFER_NINJA
    OPTIONS
        -DARROW_DEPENDENCY_SOURCE=SYSTEM
        -Duriparser_SOURCE=SYSTEM
        -DARROW_BUILD_TESTS=off
        -DARROW_PARQUET=ON
        -DARROW_BUILD_STATIC=${ARROW_BUILD_STATIC}
        -DARROW_BUILD_SHARED=${ARROW_BUILD_SHARED}
        -DARROW_GFLAGS_USE_SHARED=off
        -DARROW_JEMALLOC=off
        -DARROW_BUILD_UTILITIES=OFF
)

vcpkg_install_cmake()

vcpkg_copy_pdbs()

if(EXISTS ${CURRENT_PACKAGES_DIR}/lib/arrow_static.lib)
    message(FATAL_ERROR "Installed lib file should be named 'arrow.lib' via patching the upstream build.")
endif()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/arrow)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/lib/cmake)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib/cmake)

file(INSTALL ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/arrow RENAME copyright)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
