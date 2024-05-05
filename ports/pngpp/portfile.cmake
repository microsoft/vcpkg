# Header only library
vcpkg_download_distfile(ARCHIVE
    URLS "http://download.savannah.nongnu.org/releases/pngpp/png++-0.2.10.tar.gz"
    FILENAME "png++-0.2.10.tar.gz"
    SHA512 c54a74c0c20212bd0dcf86386c0c11dd824ad14952917ba0ff4c184b6547744458728a4f06018371acb7d5b842b641708914ccaa81bad8e72e173903f494ca85
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    PATCHES
        fix-stderror-win.patch
)

file(GLOB HEADER_FILES ${SOURCE_PATH}/*.hpp)
file(INSTALL ${HEADER_FILES} DESTINATION ${CURRENT_PACKAGES_DIR}/include/png++)
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
