include(vcpkg_common_functions)

vcpkg_download_distfile(ARCHIVE
    URLS "http://otl.sourceforge.net/otlv4_40448.zip"
    FILENAME "otlv4_h2-4.0.448.zip"
    SHA512 285bf8bb0fa38ab3030af09a2939fd8e2eaadd14e65d05c6e18f4bc12070ba4e112c41e2d38c546338d51bdf09748b158b1799599f5ed9a7959a7799869b1305
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    NO_REMOVE_ONE_LEVEL
)

file(INSTALL ${SOURCE_PATH}/otlv40448.h DESTINATION ${CURRENT_PACKAGES_DIR}/include/otl)
file(INSTALL ${SOURCE_PATH}/otlv40448.h DESTINATION ${CURRENT_PACKAGES_DIR}/share/otl RENAME copyright)
