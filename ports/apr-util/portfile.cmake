include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/apr-util-1.6.0)
vcpkg_download_distfile(ARCHIVE
  URLS "https://archive.apache.org/dist/apr/apr-util-1.6.0-win32-src.zip"
  FILENAME "apr-util-1.6.0-win32-src.zip"
  SHA512 98679ea181d3132020713481703bbefa0c174e0b2a0df65dfdd176e9771935e1f9455c4242bac19dded9414abe2b9d293fcc674ab16f96d8987bcf26346fce3a
)
vcpkg_extract_source_archive(${ARCHIVE})


vcpkg_apply_patches(
  SOURCE_PATH ${SOURCE_PATH}
  PATCHES 
        use-vcpkg-expat.patch
        apr.patch
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    vcpkg_configure_cmake(
      SOURCE_PATH ${SOURCE_PATH}
      PREFER_NINJA
      OPTIONS -DAPU_DECLARE_EXPORT=ON
      OPTIONS_DEBUG -DDISABLE_INSTALL_HEADERS=ON
    )
else()
    vcpkg_configure_cmake(
      SOURCE_PATH ${SOURCE_PATH}
      PREFER_NINJA
      OPTIONS -DAPU_DECLARE_STATIC=ON
      OPTIONS_DEBUG -DDISABLE_INSTALL_HEADERS=ON
    )
endif()

vcpkg_install_cmake()

file(READ ${CURRENT_PACKAGES_DIR}/include/apu.h  APU_H)
if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
  string(REPLACE "defined(APU_DECLARE_EXPORT)" "1" APU_H "${APU_H}")
else()
  string(REPLACE "defined(APU_DECLARE_STATIC)" "1" APU_H "${APU_H}")
endif()
file(WRITE ${CURRENT_PACKAGES_DIR}/include/apu.h "${APU_H}")


file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/apr-util RENAME copyright)

vcpkg_copy_pdbs()
