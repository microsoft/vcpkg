set(OTL_VERSION 40491)

vcpkg_download_distfile(ARCHIVE
    URLS "http://otl.sourceforge.net/otlv4_${OTL_VERSION}.zip"
    FILENAME "otlv4_${OTL_VERSION}.zip"
    SHA512 11f6e11c2eb128dea5b6d1e9eef1f033deac02f7ed063e3709969f66963bf68162f06cb11332d14a2fe341df0fb28313be49ddac0b2264e7a10a624fe662e8b1
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
