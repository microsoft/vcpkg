include(vcpkg_common_functions)

vcpkg_download_distfile(ARCHIVE
    URLS "http://otl.sourceforge.net/otlv4_h2.zip"
    FILENAME "otl-4.0.442.zip"
    SHA512 2f4005c2351021c92b86411e9c5847757b3596c485c34aa6a7228d86c446b0d9f1dcbfd228e9262d10c7460b77af0709b8ba9d5c7599ae54442efd88ccdbb96d
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE} 
    NO_REMOVE_ONE_LEVEL
    REF 4.0.422
)

file(INSTALL ${SOURCE_PATH}/otlv4.h DESTINATION ${CURRENT_PACKAGES_DIR}/include/otl)
file(INSTALL ${SOURCE_PATH}/otlv4.h DESTINATION ${CURRENT_PACKAGES_DIR}/share/otl RENAME copyright)
