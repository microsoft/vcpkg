vcpkg_download_distfile(ARCHIVE
    URLS "https://sourceforge.net/projects/xqilla/files/XQilla-2.3.4.tar.gz/download"
    FILENAME "XQilla-2.3.4.tar.gz"
    SHA512 f744ff883675887494780d24ecdc94afa394d3795d1544b1c598016b3f936c340ad7cd84529ac12962e3c5ce2f1be928a0cd4f9b9eb70e6645a38b0728cb1994
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
	PATCHES "fix-compare.patch"
)

if (VCPKG_LIBRARY_LINKAGE STREQUAL "static")
   list(APPEND COMPILE_OPTIONS "-DXQILLA_STATIC=static")
endif()


if(VCPKG_TARGET_IS_LINUX)
  list(APPEND CONFIGURE_OPTIONS "--with-xerces=${CURRENT_INSTALLED_DIR}")
  if (VCPKG_LIBRARY_LINKAGE STREQUAL "static")
	list(APPEND CONFIGURE_OPTIONS "--enable-static")
  elseif(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    list(APPEND CONFIGURE_OPTIONS "--enable-shared")	
  endif()
  vcpkg_configure_make(
      SOURCE_PATH "${SOURCE_PATH}"
	  AUTOCONFIG
	  OPTIONS ${CONFIGURE_OPTIONS}
  )
  
  vcpkg_install_make()
  vcpkg_fixup_pkgconfig()
else()
  file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")
  vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
	WINDOWS_USE_MSBUILD
	OPTIONS 
		${COMPILE_OPTIONS}
  )
  vcpkg_cmake_install()
endif()

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION ${CURRENT_PACKAGES_DIR}/share/xqilla RENAME copyright)
