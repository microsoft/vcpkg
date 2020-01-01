# Random123 - Header-only library

include(vcpkg_common_functions)

set(VERSION 1.09)

vcpkg_download_distfile( 
    ARCHIVE
    URLS "http://www.deshawresearch.com/downloads/download_random123.cgi/Random123-${VERSION}.tar.gz"
    FILENAME "Random123-${VERSION}.tar.gz "
    SHA512 7bd72dffa53ca8d835b4a4cf49171618cd46f4b329d7a09486efaf2e1565c98b80ff05e3bccc244fabd7013f139058511fb2e39399bfe51fd6b68cd9e63da1ac
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
)

# Copy the headers that define this package to the install location.
file(GLOB header_files 
     ${SOURCE_PATH}/include/Random123/*.h 
     ${SOURCE_PATH}/include/Random123/*.hpp ) 
file(COPY ${header_files}
     DESTINATION ${CURRENT_PACKAGES_DIR}/include/${PORT} )
file(COPY ${SOURCE_PATH}/include/Random123/conventional
     DESTINATION ${CURRENT_PACKAGES_DIR}/include/${PORT} )
file(COPY ${SOURCE_PATH}/include/Random123/features
     DESTINATION ${CURRENT_PACKAGES_DIR}/include/${PORT} )

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
