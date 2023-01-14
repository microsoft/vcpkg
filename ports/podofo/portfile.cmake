set(PODOFO_VERSION 0.9.8)

if (VCPKG_TARGET_IS_UWP)
  set(ADDITIONAL_PATCH "0003-uwp_fix.patch")
endif()

vcpkg_from_sourceforge(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO podofo/podofo
    REF ${PODOFO_VERSION}
    FILENAME "podofo-${PODOFO_VERSION}.tar.gz"
    SHA512 b220322114450f1656c73d325f5172bc4cec0b1913e98b4eb2455f8ed7394bcaa47438d41003c9678937ef44d411e135431ddd6784f83d3663337d471baa02b1
    PATCHES
        0002-HAVE_UNISTD_H.patch
        freetype.patch
        ${ADDITIONAL_PATCH}
        0005-fix-crypto.patch
        fix-x64-osx.patch
        install-cmake-config.patch
        fix-compiler.patch
)

set(PODOFO_NO_FONTMANAGER ON)
if("fontconfig" IN_LIST FEATURES)
  set(PODOFO_NO_FONTMANAGER OFF)
endif()

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" PODOFO_BUILD_SHARED)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" PODOFO_BUILD_STATIC)

set(IS_WIN32 OFF)
if(VCPKG_TARGET_IS_WINDOWS)
    set(IS_WIN32 ON)
endif()

file(REMOVE "${SOURCE_PATH}/cmake/modules/FindOpenSSL.cmake")
file(REMOVE "${SOURCE_PATH}/cmake/modules/FindZLIB.cmake")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DPODOFO_BUILD_LIB_ONLY=1
        -DPODOFO_BUILD_SHARED=${PODOFO_BUILD_SHARED}
        -DPODOFO_BUILD_STATIC=${PODOFO_BUILD_STATIC}
        -DPODOFO_NO_FONTMANAGER=${PODOFO_NO_FONTMANAGER}
        -DCMAKE_DISABLE_FIND_PACKAGE_FONTCONFIG=${PODOFO_NO_FONTMANAGER}
        -DCMAKE_DISABLE_FIND_PACKAGE_LIBCRYPTO=${IS_WIN32}
        -DCMAKE_DISABLE_FIND_PACKAGE_LIBIDN=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_CppUnit=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_Boost=ON
    MAYBE_UNUSED_VARIABLES
        CMAKE_DISABLE_FIND_PACKAGE_Boost
        CMAKE_DISABLE_FIND_PACKAGE_CppUnit
        CMAKE_DISABLE_FIND_PACKAGE_LIBCRYPTO
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

vcpkg_replace_string( "${CURRENT_PACKAGES_DIR}/share/${PORT}/PoDoFoConfig.cmake"
    "# Create imported target podofo_shared"
[[
include(CMakeFindDependencyMacro)
find_dependency(OpenSSL)
# Create imported target podofo_shared
]]
)

vcpkg_cmake_config_fixup()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
