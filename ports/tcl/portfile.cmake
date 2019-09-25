vcpkg_download_distfile(ARCHIVE
    URLS "https://prdownloads.sourceforge.net/tcl/tcl8.6.9-src.tar.gz"
    FILENAME "tcl8.6.9-src.tar.gz"
    SHA512 707fc0fb4f45c85e8f21692e5035d727cde27d87a2e1cd2e748ad373ebd3517aeca25ecaef3382a2f0e0a1feff96ce94a62b87abcf085e1a0afe2a23ef460112
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
)

if (VCPKG_TARGET_IS_WINDOWS)
    if(VCPKG_TARGET_ARCHITECTURE MATCHES "x64")
        set(MACHINE_STR AMD64)
    else()
        set(MACHINE_STR IX86)
    endif()
    
    vcpkg_install_nmake(
        SOURCE_PATH ${SOURCE_PATH}
        PROJECT_SUBPATH win
        OPTIONS
            MACHINE=${MACHINE_STR}
            OPTS=pdbs
            OPTS=symbols
        OPTIONS_DEBUG
            OPTS=symbols
    )

else()
    vcpkg_configure_make(
        SOURCE_PATH ${SOURCE_PATH}
        PROJECT_SUBPATH unix
    )
    
    vcpkg_install_make()
endif()

file(INSTALL ${SOURCE_PATH}/license.terms DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)