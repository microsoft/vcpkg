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
        NO_DEBUG
        OPTIONS
            MACHINE=${MACHINE_STR}
            OPTS=pdbs
            OPTS=symbols
    )

    file(GLOB_RECURSE TOOLS
            ${CURRENT_PACKAGES_DIR}/lib/dde1.4/*
            ${CURRENT_PACKAGES_DIR}/lib/nmake/*
            ${CURRENT_PACKAGES_DIR}/lib/reg1.3/*
            ${CURRENT_PACKAGES_DIR}/lib/tcl8/*
            ${CURRENT_PACKAGES_DIR}/lib/tcl8.6/*
            ${CURRENT_PACKAGES_DIR}/lib/tdbcsqlite31.1.0/*
    )
    foreach(TOOL ${TOOLS})
        get_filename_component(DST_DIR ${TOOL} PATH)
        string(REPLACE "${${CURRENT_PACKAGES_DIR}/lib/}" "${${CURRENT_PACKAGES_DIR}/tools/}" DST_DIR "${DST_DIR}")
        file(COPY ${TOOL} DESTINATION ${DST_DIR})
        file(REMOVE ${TOOL})
    endforeach()
else()
    vcpkg_configure_make(
        SOURCE_PATH ${SOURCE_PATH}
        NO_DEBUG
        PROJECT_SUBPATH unix
    )
    
    vcpkg_install_make()
    
    if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
        file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
    endif()
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include ${CURRENT_PACKAGES_DIR}/debug/share)
endif()

file(INSTALL ${SOURCE_PATH}/license.terms DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)