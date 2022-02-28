set(OTL_VERSION 40463)

vcpkg_download_distfile(ARCHIVE
    URLS "http://otl.sourceforge.net/otlv4_${OTL_VERSION}.zip"
    FILENAME "otlv4_${OTL_VERSION}-9485a0fe15a7-1.zip"
    SHA512 46a50234009ca8e8dba3b0b781f4b496759f4c5697f045d816c7e4eddda61da63d03acf29b4d1f71ee035aba4c6daa72c9a546085a6d7b3c192353b854526392
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
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
