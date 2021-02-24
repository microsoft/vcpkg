vcpkg_download_distfile(ARCHIVE
  URLS "http://www.fadbad.com/download/FADBAD++-2.1.tar.gz"
  FILENAME "FADBAD++-2.1.tar.gz"
  SHA512 7a82c51c03acb0806d673853f391379ea974e304c831ee15ef05a90c30661736ff572481b5b8254b2646c63968043ee90a06cba88261b87fc34d01f92403360a
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
)

file(INSTALL
  ${SOURCE_PATH}/tadiff.h
  ${SOURCE_PATH}/fadbad.h
  ${SOURCE_PATH}/fadiff.h
  ${SOURCE_PATH}/badiff.h
  DESTINATION ${CURRENT_PACKAGES_DIR}/include
)

file(INSTALL ${SOURCE_PATH}/COPYRIGHT DESTINATION ${CURRENT_PACKAGES_DIR}/share/fadbad RENAME copyright)
