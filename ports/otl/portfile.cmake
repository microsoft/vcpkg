set(OTL_VERSION 40451)

vcpkg_download_distfile(ARCHIVE
    URLS "http://otl.sourceforge.net/otlv4_${OTL_VERSION}.zip"
    FILENAME "otlv4_${OTL_VERSION}.zip"
    SHA512 add1e54fae20175461d5f09cbe324e98b6f6a3839356136811109cf3251ca96541c101816870c6cc15d7611ad6bf9d576ac8dfce4274419b30866955c5892d15
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
