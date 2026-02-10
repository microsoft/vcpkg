vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO asmjit/asmtk
    REF 1261a46fabb0b353be1f52ff77b0245aa9c170f4 # accessed on 2025-12-28
    SHA512 caa2bdd3d70f809fcf25fe06bb125eb45c4cf7687444614f08e4344855120b0b3838bc13784da958738b9546988f8abd22a868ccaa81dd4f05173a35a9e471b6
    HEAD_REF master
    PATCHES
      fix-link-amsjit.patch
)

set(ASMJIT_EXTERNAL ON)
set(ASMTK_EMBED OFF)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" ASMTK_STATIC)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DASMTK_STATIC=${ASMTK_STATIC}
        -DASMJIT_EXTERNAL=${ASMJIT_EXTERNAL}
        -DASMTK_EMBED=${ASMTK_EMBED}
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/asmtk)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
  vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/asmtk/globals.h" "!defined(ASMTK_STATIC)" "0")
endif()

set(cmakefile "${CURRENT_PACKAGES_DIR}/share/asmtk/asmtk-config.cmake")
file(READ "${cmakefile}" contents)
file(WRITE "${cmakefile}" "include(CMakeFindDependencyMacro)\nfind_dependency(asmjit)\n${contents}")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.md")
