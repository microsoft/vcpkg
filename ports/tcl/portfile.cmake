vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO tcltk/tcl
    REF 54ea3ef1f5f651192316dace49ff9593fcbf6cf0
    SHA512 b9c6567d77838635ed6b440ae3aea1ea5c421e474136fe5905b6c7db48ab32811cf15a2b0201ccbdb02b9c5e68e9880e48ab611f9c8054fdbf8ee9f784c0b61a)

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