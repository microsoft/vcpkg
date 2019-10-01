include(vcpkg_common_functions)

vcpkg_download_distfile(ARCHIVE
    URLS "http://otl.sourceforge.net/otlv4_h2.zip"
    FILENAME "otl-4.0.443.zip"
    SHA512 ee866971a7546c5fbfcdde07c63eb2bbfc2c2a681174eb58b77e7ccb55af08e80674c40267ca7762136aa422eca2d8456e668d7ee495a43d8378fdfad084184b
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    NO_REMOVE_ONE_LEVEL
    REF 4.0.443
)

file(INSTALL ${SOURCE_PATH}/otlv4.h DESTINATION ${CURRENT_PACKAGES_DIR}/include/otl)
file(INSTALL ${SOURCE_PATH}/otlv4.h DESTINATION ${CURRENT_PACKAGES_DIR}/share/otl RENAME copyright)
