include(vcpkg_common_functions)

vcpkg_download_distfile(ARCHIVE
    URLS "http://otl.sourceforge.net/otlv4_h2.zip"
    FILENAME "otlv4_h2-4.0.443.zip"
    SHA512 90a90d909586aae2088c87b5899244c01eef58aed7183d73b9be647f9c7a7bdcdc2f50f5c3cb564330b0061fb63e85f1b5522b4cf9390bc9baa5e2cb97ea3f3e
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    NO_REMOVE_ONE_LEVEL
)

file(INSTALL ${SOURCE_PATH}/otlv4.h DESTINATION ${CURRENT_PACKAGES_DIR}/include/otl)
file(INSTALL ${SOURCE_PATH}/otlv4.h DESTINATION ${CURRENT_PACKAGES_DIR}/share/otl RENAME copyright)
