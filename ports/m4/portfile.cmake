
set(VERSION 1.4.19)
set(SHA512 f5dd0f02fcae65a176a16af9a8e1747c26e9440c6c224003ba458d3298b777a75ffb189aee9051fb0c4840b2a48278be4a51d959381af0b1d627570f478c58f2)
# cmake-format: off
vcpkg_download_distfile(ARCHIVE
    URLS "https://ftp.gnu.org/gnu/m4/m4-${VERSION}.tar.gz"
    FILENAME "m4-${VERSION}.tar.gz"
    SHA512 ${SHA512}
)

if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "Linux")
  vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH
    SOURCE_PATH
    ARCHIVE ${ARCHIVE})

  vcpkg_configure_make(
    SOURCE_PATH "${SOURCE_PATH}"
    AUTOCONFIG
    OPTIONS
  )
# cmake-format: on

  vcpkg_install_make()

  vcpkg_copy_pdbs()
else()

endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
# Allow empty include directory
set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)

file(
  INSTALL ${SOURCE_PATH}/COPYING
  DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT}
  RENAME copyright)
