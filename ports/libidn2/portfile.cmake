set(IDN2_VERSION 2.3.1)
set(IDN2_FILENAME libidn2-${IDN2_VERSION}.tar.gz)

vcpkg_download_distfile(ARCHIVE
    URLS "https://ftp.gnu.org/gnu/libidn/${IDN2_FILENAME}" "https://www.mirrorservice.org/sites/ftp.gnu.org/gnu/libidn/${IDN2_FILENAME}"
    FILENAME "${IDN2_FILENAME}"
    SHA512 4d77a4a79e08a05e46fc14827f987b9e7645ebf5d0c0869eb96f9902c2f6b73ea69fd6f9f97b80a9f07cce84f7aa299834df91485d4e7c16500d31a4b9865fe4
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
    configure_file("${SOURCE_PATH}/gl/alloca.in.h" "${SOURCE_PATH}/gl/alloca.h")
    
    function(simple_copy_template_header FILE_PATH BASE_NAME)
        if(NOT EXISTS "${FILE_PATH}/${BASE_NAME}.h" AND EXISTS "${FILE_PATH}/${BASE_NAME}.in.h")
            configure_file("${FILE_PATH}/${BASE_NAME}.in.h" "${FILE_PATH}/${BASE_NAME}.h" @ONLY)
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
