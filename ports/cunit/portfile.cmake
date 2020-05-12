include(vcpkg_common_functions)

vcpkg_download_distfile(ARCHIVE
  URLS "http://downloads.sourceforge.net/project/cunit/CUnit/2.1-3/CUnit-2.1-3.tar.bz2"
  FILENAME "CUnit-2.1-3.tar.bz2"
  SHA512 547b417109332446dfab8fda17bf4ccd2da841dc93f824dc90a20635bcf1fb80fb2176500d8a0906940f3f3d3e2f77b2d70a71090c9ab84ad9af43f3582bc487
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
  SOURCE_PATH ${SOURCE_PATH}
  PREFER_NINJA
  OPTIONS_DEBUG -DDISABLE_INSTALL_HEADERS=ON
)

vcpkg_install_cmake()

file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/cunit RENAME copyright)

vcpkg_copy_pdbs()
