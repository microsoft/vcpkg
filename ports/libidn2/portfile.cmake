set(IDN2_VERSION 2.3.0)
set(IDN2_FILENAME libidn2-${IDN2_VERSION}.tar.gz)

vcpkg_download_distfile(ARCHIVE
    URLS "https://ftp.gnu.org/gnu/libidn/${IDN2_FILENAME}" "https://www.mirrorservice.org/sites/ftp.gnu.org/gnu/libidn/${IDN2_FILENAME}"
    FILENAME "${IDN2_FILENAME}"
    SHA512 a2bf6d2249948bce14fbbc802f8af1c9b427fc9bf64203a2f3d7239d8e6061d0a8e7970a23e8e5889110a654a321e0504c7a6d049bb501e7f6a23d42b50b6187
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    REF ${IDN2_VERSION}
)

if (VCPKG_TARGET_IS_WINDOWS)
    file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")
    file(COPY "${CMAKE_CURRENT_LIST_DIR}/string.h" DESTINATION "${SOURCE_PATH}/gl")
    
    set(HAVE_ALLOCA_H 0)
    
    configure_file("${CMAKE_CURRENT_LIST_DIR}/config.h" "${SOURCE_PATH}")
    
    function(simple_copy_template_header FILE_PATH BASE_NAME)
        if(NOT EXISTS "${FILE_PATH}/${BASE_NAME}.h" AND EXISTS "${FILE_PATH}/${BASE_NAME}.in.h")
            configure_file("${FILE_PATH}/${BASE_NAME}.in.h" "${FILE_PATH}/${BASE_NAME}.h")
        endif()
    endfunction()
    
    # There seems to be no difference between source and destination files after 'configure'
    # apart from auto-generated notification at the top. So why not just do a simple copy.
    simple_copy_template_header("${SOURCE_PATH}/unistring" uniconv)
    simple_copy_template_header("${SOURCE_PATH}/unistring" unictype)
    simple_copy_template_header("${SOURCE_PATH}/unistring" uninorm)
    simple_copy_template_header("${SOURCE_PATH}/unistring" unistr)
    simple_copy_template_header("${SOURCE_PATH}/unistring" unitypes)
    simple_copy_template_header("${SOURCE_PATH}/unistring" alloca)
    
    vcpkg_cmake_configure(
        SOURCE_PATH "${SOURCE_PATH}"
        OPTIONS
            "-DPACKAGE_VERSION=${IDN2_VERSION}"
    )
    
    vcpkg_cmake_install()
    
    vcpkg_copy_pdbs()
    
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

else()
    set(ENV{GTKDOCIZE} true)
    vcpkg_configure_make(
        SOURCE_PATH "${SOURCE_PATH}"
        AUTOCONFIG
        COPY_SOURCE
        OPTIONS
            "--with-libiconv-prefix=${CURRENT_INSTALLED_DIR}"
            --disable-gtk-doc
            --disable-doc
    )
    
    vcpkg_install_make()
    
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
endif()

vcpkg_fixup_pkgconfig()

# License and man
file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/libidn2" RENAME copyright)
file(INSTALL "${SOURCE_PATH}/doc/libidn2.pdf" DESTINATION "${CURRENT_PACKAGES_DIR}/share/libidn2")
