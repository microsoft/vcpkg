set(OTL_VERSION 40463)

vcpkg_download_distfile(ARCHIVE
    URLS "http://otl.sourceforge.net/otlv4_${OTL_VERSION}.zip"
    FILENAME "otlv4_${OTL_VERSION}-9485a0fe15a7.zip"
    SHA512 9485a0fe15a737d55b0746a7e289b1a20e9435ed5c69bda7010705f8cde0a456163d83221d0103236a723837596613b578edc6d3d0007ce80a6cc76b4ed83888
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
