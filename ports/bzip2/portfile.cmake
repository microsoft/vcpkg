vcpkg_from_git(
    OUT_SOURCE_PATH SOURCE_PATH
    URL https://sourceware.org/git/bzip2.git
    REF 75a94bea3918e612b879d6a11ca64b8689526147
    PATCHES
        fix-import-export-macros.patch
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS_DEBUG
        -DBZIP2_SKIP_HEADERS=ON
        -DBZIP2_SKIP_TOOLS=ON
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

file(READ "${CURRENT_PACKAGES_DIR}/include/bzlib.h" BZLIB_H)
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    string(REPLACE "defined(BZ_IMPORT)" "0" BZLIB_H "${BZLIB_H}")
else()
    string(REPLACE "defined(BZ_IMPORT)" "1" BZLIB_H "${BZLIB_H}")
endif()
file(WRITE "${CURRENT_PACKAGES_DIR}/include/bzlib.h" "${BZLIB_H}")

if (NOT VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
  set(BZIP2_PREFIX "${CURRENT_INSTALLED_DIR}")
  set(bzname bz2)
  configure_file("${CMAKE_CURRENT_LIST_DIR}/bzip2.pc.in" "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/bzip2.pc" @ONLY)
endif()

if (NOT VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
  set(BZIP2_PREFIX "${CURRENT_INSTALLED_DIR}/debug")
  set(bzname bz2d)
  configure_file("${CMAKE_CURRENT_LIST_DIR}/bzip2.pc.in" "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/bzip2.pc" @ONLY)
endif()

vcpkg_fixup_pkgconfig()

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
file(COPY "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
