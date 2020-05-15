set(OTL_VERSION 40455)

vcpkg_download_distfile(ARCHIVE
    URLS "http://otl.sourceforge.net/otlv4_${OTL_VERSION}.zip"
    FILENAME "otlv4_${OTL_VERSION}.zip"
    SHA512 2d5c52af3eafdd93bf7c651de218607b8985acc1fce279d48d9bf58ecf8a012332c8d0b9a33223a6449f343134211e2d7c5412b71efb36ba484bda754e1afc45
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    NO_REMOVE_ONE_LEVEL
)

file(INSTALL "${SOURCE_PATH}/otlv${OTL_VERSION}.h" 
    DESTINATION "${CURRENT_PACKAGES_DIR}/include/${PORT}" 
    RENAME otlv4.h)

file(INSTALL "${SOURCE_PATH}/otlv${OTL_VERSION}.h" 
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" 
    RENAME copyright)
