include(vcpkg_common_functions)

vcpkg_download_distfile(ARCHIVE
    URLS "http://otl.sourceforge.net/otlv4_h2.zip"
    FILENAME "otlv4_h2-4.0.447.zip"
    SHA512 07663442272a327a7d9154f6e817c0166ed254cfe3b9d043762179e96180a70d3ba4b3762e5ef1ebdb18492e3425467c9ddad3a2c68aa93bb7d51d54e9712008
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    NO_REMOVE_ONE_LEVEL
)

file(INSTALL ${SOURCE_PATH}/otlv4.h DESTINATION ${CURRENT_PACKAGES_DIR}/include/otl)
file(INSTALL ${SOURCE_PATH}/otlv4.h DESTINATION ${CURRENT_PACKAGES_DIR}/share/otl RENAME copyright)
