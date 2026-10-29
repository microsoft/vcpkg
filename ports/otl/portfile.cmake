set(OTL_VERSION 40509)

vcpkg_download_distfile(ARCHIVE
    URLS "http://otl.sourceforge.net/otlv4_${OTL_VERSION}.zip"
    FILENAME "otlv4_${OTL_VERSION}.zip"
    SHA512 235536b9f49fb05016bf118c610fd1f078bde961a69ba56f6d746c30ec2ee1753c1d0d72948fd73c7aa5a38ec8e605c133544789ccdee0d678751bb62872d3c2
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    NO_REMOVE_ONE_LEVEL
)

file(INSTALL "${SOURCE_PATH}/otlv${OTL_VERSION}.h"
    DESTINATION "${CURRENT_PACKAGES_DIR}/include/${PORT}"
    RENAME otlv4.h)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/otlv${OTL_VERSION}.h")
