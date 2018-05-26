include(vcpkg_common_functions)

set(IDN2_VERSION 2.0.4)
set(IDN2_FILENAME libidn2-${IDN2_VERSION}.tar.gz)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/libidn2-${IDN2_VERSION})

vcpkg_download_distfile(ARCHIVE
    URLS "http://ftp.gnu.org/gnu/libidn/${IDN2_FILENAME}"
    FILENAME "${IDN2_FILENAME}"
    SHA512 1e51bd4b8f8907531576291f1c2a8865d17429b4105418b4c98754eb982cd1cbb3adbeab4ec0c1c561d2dba11d876c7c09e5dc5b315c55a2c24986d7a2a3b4d2
)
vcpkg_extract_source_archive(${ARCHIVE})

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

file(COPY ${CMAKE_CURRENT_LIST_DIR}/config.h DESTINATION ${SOURCE_PATH})
file(COPY ${CMAKE_CURRENT_LIST_DIR}/string.h DESTINATION ${SOURCE_PATH}/gl)

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
