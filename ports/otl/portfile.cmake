set(OTL_VERSION 40448)

vcpkg_download_distfile(ARCHIVE
    URLS "http://otl.sourceforge.net/otlv4_${OTL_VERSION}.zip"
    FILENAME "otl-v${OTL_VERSION}.zip"
    SHA512 3ddc7efb79e0f8349783b18fd8c95a778721a7589f4a69168365c072e8fa09f7ec9679c89dcceb844b16e816c6e561f995f1fdd50e8df983e7ff0186083c246c
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    NO_REMOVE_ONE_LEVEL
)

file(INSTALL "${SOURCE_PATH}/otlv${OTL_VERSION}.h" 
    DESTINATION "${CURRENT_PACKAGES_DIR}/include/otl" 
    RENAME otlv4.h)

file(INSTALL "${SOURCE_PATH}/otlv${OTL_VERSION}.h" 
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/otl" 
    RENAME copyright)
