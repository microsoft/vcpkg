
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO podofo/podofo
    REF "${VERSION}"
    SHA512 674024af031392253bc9ea02e392fa7b4a5c8894f3129e05f27133774ccf8b696e225789e886dedbe90bc2323c318b76e79857453a56d6014d7a5514e3f861a2
    PATCHES
        install-cmake-config.patch
)

set(PODOFO_NO_FONTMANAGER ON)
if("fontconfig" IN_LIST FEATURES)
  set(PODOFO_NO_FONTMANAGER OFF)
endif()

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

vcpkg_replace_string( "${CURRENT_PACKAGES_DIR}/share/${PORT}/podofo-config.cmake"
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
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
