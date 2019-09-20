include(vcpkg_common_functions)

vcpkg_download_distfile(ARCHIVE
    # This URL is not stable becuase they use the same name for minor releases which changes the hash below.
    # if you know a stable download URL then please update it.
    URLS "http://otl.sourceforge.net/otlv4_h2.zip"
    FILENAME "otl-4.0.443.zip"
    SHA512 7f1e9080f097da648050dcc60e5e54f7801bbdcbd5e4609dc14424a1881995c06f045e92bdabfca754461324dbf0e882c8542816799c4ec3c0a1a7fc6c150fa4
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE} 
    NO_REMOVE_ONE_LEVEL
    REF 4.0.443
)

file(INSTALL ${SOURCE_PATH}/otlv4.h DESTINATION ${CURRENT_PACKAGES_DIR}/include/otl)
file(INSTALL ${SOURCE_PATH}/otlv4.h DESTINATION ${CURRENT_PACKAGES_DIR}/share/otl RENAME copyright)
