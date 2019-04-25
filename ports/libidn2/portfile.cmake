include(vcpkg_common_functions)

set(IDN2_VERSION 2.1.1)
set(IDN2_FILENAME libidn2-${IDN2_VERSION}a.tar.gz)

vcpkg_download_distfile(ARCHIVE
    URLS "http://ftp.gnu.org/gnu/libidn/${IDN2_FILENAME}"
    FILENAME "${IDN2_FILENAME}"
    SHA512 404a739e33d324f700ac8e8119de3feef0de778bbb11be09049cb64eab447cd101883f6d489cca1e88c230f58bcaf9758fe102e571b6501450aa750ec2a4a9c6
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    REF ${IDN2_VERSION}
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})
file(COPY ${CMAKE_CURRENT_LIST_DIR}/string.h DESTINATION ${SOURCE_PATH}/gl)

configure_file(${CMAKE_CURRENT_LIST_DIR}/config.h ${SOURCE_PATH})

function(simple_copy_template_header FILE_PATH BASE_NAME)
    if(NOT EXISTS ${FILE_PATH}/${BASE_NAME}.h)
       if(EXISTS ${FILE_PATH}/${BASE_NAME}.in.h)
           configure_file(${FILE_PATH}/${BASE_NAME}.in.h ${FILE_PATH}/${BASE_NAME}.h)
       endif()
    endif()
endfunction()

# There seems to be no difference between source and destination files after 'configure'
# apart from auto-generated notification at the top. So why not just do a simple copy.
simple_copy_template_header(${SOURCE_PATH}/unistring uniconv)
simple_copy_template_header(${SOURCE_PATH}/unistring unictype)
simple_copy_template_header(${SOURCE_PATH}/unistring uninorm)
simple_copy_template_header(${SOURCE_PATH}/unistring unistr)
simple_copy_template_header(${SOURCE_PATH}/unistring unitypes)
simple_copy_template_header(${SOURCE_PATH}/unistring alloca)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# License and man
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/libidn2 RENAME copyright)
file(INSTALL ${SOURCE_PATH}/doc/libidn2.pdf DESTINATION ${CURRENT_PACKAGES_DIR}/share/libidn2)

vcpkg_copy_pdbs()
