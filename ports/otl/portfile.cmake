set(OTL_VERSION 40508)

vcpkg_download_distfile(ARCHIVE
    URLS "http://otl.sourceforge.net/otlv4_${OTL_VERSION}.zip"
    FILENAME "otlv4_${OTL_VERSION}.zip"
    SHA512 069cff1dabd026e7ea0dcefefec022fe1e830e91fe3593e9fe4f742b64a7d67e497c7d462f6382e2152cf29f7b77d234153ab29ffa4182825e19286b874a5d34
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    NO_REMOVE_ONE_LEVEL
    PATCHES fix-row-status-delete.patch
)

file(INSTALL "${SOURCE_PATH}/otlv${OTL_VERSION}.h"
    DESTINATION "${CURRENT_PACKAGES_DIR}/include/${PORT}"
    RENAME otlv4.h)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/otlv${OTL_VERSION}.h")
