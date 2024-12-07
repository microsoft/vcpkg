set(OTL_VERSION 40478)

vcpkg_download_distfile(ARCHIVE
    URLS "http://otl.sourceforge.net/otlv4_${OTL_VERSION}.zip"
    FILENAME "otlv4_${OTL_VERSION}.zip"
    SHA512 dcc2289a31150ae59568a04156ad2e260fb925708404c34e05f0e5ba7b955792ab947566b19e4996ee0a1e19b2f6c18674344c73e908f8f5e71fe3e65817908e
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    NO_REMOVE_ONE_LEVEL
)

file(INSTALL "${SOURCE_PATH}/otlv${OTL_VERSION}.h"
    DESTINATION "${CURRENT_PACKAGES_DIR}/include/${PORT}"
    RENAME otlv4.h)

file(READ "${SOURCE_PATH}/otlv${OTL_VERSION}.h" copyright_contents)
string(FIND "${copyright_contents}" "#ifndef OTL_H" start_of_source)
if(start_of_source EQUAL "-1")
    message(FATAL_ERROR "Could not find start of source; the header file has changed in a way that we cannot get the license text.")
endif()
string(SUBSTRING "${copyright_contents}" 0 "${start_of_source}" copyright_contents)
string(REGEX REPLACE "// ?" "" copyright_contents "${copyright_contents}")
string(REGEX REPLACE "=+\n" "" copyright_contents "${copyright_contents}")

file(WRITE
    "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright"
    "${copyright_contents}"
)
