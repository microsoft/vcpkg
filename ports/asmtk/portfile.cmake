vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO asmjit/asmtk
    REF f2f268314afa54f28b50b86df5c0954ca71d540a # accessed on 2025-08-06
    SHA512 864b61cfab1f822d3eaf28c11b89d564b93b4ff3749e74d2285d940ae49621af10716c2851c809d290b1f570e0edd8fd37a33eeabb4efaed516b0708aa14af9a
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
