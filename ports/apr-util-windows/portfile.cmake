
vcpkg_download_distfile(ARCHIVE
  URLS "https://archive.apache.org/dist/apr/apr-util-1.6.0-win32-src.zip"
  FILENAME "apr-util-1.6.0-win32-src.zip"
  SHA512 98679ea181d3132020713481703bbefa0c174e0b2a0df65dfdd176e9771935e1f9455c4242bac19dded9414abe2b9d293fcc674ab16f96d8987bcf26346fce3a
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    PATCHES
        use-vcpkg-expat.patch
        apr.patch
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
  set(APU_DECLARE_EXPORT ON)
  set(APU_DECLARE_STATIC OFF)
else()
  set(APU_DECLARE_EXPORT OFF)
  set(APU_DECLARE_STATIC ON)
endif()

vcpkg_configure_cmake(
  SOURCE_PATH ${SOURCE_PATH}
  PREFER_NINJA
  OPTIONS
    -DAPU_DECLARE_EXPORT=${APU_DECLARE_EXPORT}
    -DAPU_DECLARE_STATIC=${APU_DECLARE_STATIC}
  OPTIONS_DEBUG
    -DDISABLE_INSTALL_HEADERS=ON
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

file(READ ${CURRENT_PACKAGES_DIR}/include/apu.h  APU_H)
if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
  string(REPLACE "defined(APU_DECLARE_EXPORT)" "1" APU_H "${APU_H}")
else()
  string(REPLACE "defined(APU_DECLARE_STATIC)" "1" APU_H "${APU_H}")
endif()
file(WRITE ${CURRENT_PACKAGES_DIR}/include/apu.h "${APU_H}")

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
