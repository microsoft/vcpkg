include(vcpkg_common_functions)
vcpkg_download_distfile(ARCHIVE
    URLS "http://downloads.sourceforge.net/project/wtl/WTL%209.1/WTL%209.1.5321%20Final/WTL91_5321_Final.zip?r=&ts=1477467616&use_mirror=netix"
    FILENAME "WTL91_5321_Final.zip"
    SHA512 52c583f6773839f7ad7fccf0ecba44ad00f41af4ae97d217619cc380ea9b71b90638ae35a5995f9eb08854db423896fec5f06b5cbd853f118eeddd05238a460a
)
vcpkg_extract_source_archive(${ARCHIVE})

file(INSTALL ${CURRENT_BUILDTREES_DIR}/src/include/ DESTINATION ${CURRENT_PACKAGES_DIR}/include/wtl FILES_MATCHING PATTERN "*.h")

file(COPY ${CURRENT_BUILDTREES_DIR}/src/MS-PL.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/wtl)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/wtl/MS-PL.txt ${CURRENT_PACKAGES_DIR}/share/wtl/copyright)

file(COPY ${CURRENT_BUILDTREES_DIR}/src/samples DESTINATION ${CURRENT_PACKAGES_DIR}/share/wtl)
