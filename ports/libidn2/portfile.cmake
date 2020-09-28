set(IDN2_VERSION 2.2.0)
set(IDN2_FILENAME libidn2-${IDN2_VERSION}.tar.gz)

vcpkg_download_distfile(ARCHIVE
    URLS "https://ftp.gnu.org/gnu/libidn/${IDN2_FILENAME}" "https://www.mirrorservice.org/sites/ftp.gnu.org/gnu/libidn/${IDN2_FILENAME}"
    FILENAME "${IDN2_FILENAME}"
    SHA512 ccf56056a378d49a28ff67a2a23cd3d32ce51f86a78f84839b98dad709a1d0d03ac8d7c1496f0e4d3536bca00e3d09d34d76a37317b2ce87e3aa66bdf4e877b8
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    REF ${IDN2_VERSION}
)

if (VCPKG_TARGET_IS_WINDOWS)
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
    
    vcpkg_copy_pdbs()
    
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

else()
    vcpkg_configure_make(
        SOURCE_PATH ${SOURCE_PATH}
        COPY_SOURCE
        OPTIONS
            --with-libiconv-prefix=${CURRENT_INSTALLED_DIR}
    )
    
    vcpkg_install_make()
    
    vcpkg_fixup_pkgconfig()
    
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
endif()

# License and man
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/libidn2 RENAME copyright)
file(INSTALL ${SOURCE_PATH}/doc/libidn2.pdf DESTINATION ${CURRENT_PACKAGES_DIR}/share/libidn2)
