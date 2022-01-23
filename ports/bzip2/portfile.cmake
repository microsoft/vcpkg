set(BZIP2_VERSION 1.0.8)
vcpkg_download_distfile(ARCHIVE
    URLS "https://sourceware.org/pub/bzip2/bzip2-${BZIP2_VERSION}.tar.gz"
    FILENAME "bzip2-${BZIP2_VERSION}.tar.gz"
    SHA512 083f5e675d73f3233c7930ebe20425a533feedeaaa9d8cc86831312a6581cefbe6ed0d08d2fa89be81082f2a5abdabca8b3c080bf97218a1bd59dc118a30b9f3
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    PATCHES fix-import-export-macros.patch
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS_DEBUG
        -DBZIP2_SKIP_HEADERS=ON
        -DBZIP2_SKIP_TOOLS=ON
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/bzlib.h" "defined(BZ_IMPORT)" "0")
else()
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/bzlib.h" "defined(BZ_IMPORT)" "1")
endif()

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
