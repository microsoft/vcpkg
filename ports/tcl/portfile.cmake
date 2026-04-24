vcpkg_download_distfile(ARCHIVE
    URLS "https://sourceforge.net/projects/tcl/files/Tcl/${VERSION}/tcl${VERSION}-src.tar.gz/download"
    FILENAME "tcl${VERSION}-src.tar.gz"
    SHA512 a899333fd96f139d92ad74ee42cc402428677ab2cab8ed3eb1e6e7cb35c7ca7d39aac89b7755b2fb1786512c857c79486d71f49a7821470f669fb9e544dba532

)
vcpkg_extract_source_archive(SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    PATCHES
        nmake.diff
        wip.diff
)
file(GLOB sqlite3_sources "${SOURCE_PATH}/pkgs/sqlite3.51.0/compat/*.c" "${SOURCE_PATH}/pkgs/sqlite3.51.0/compat/*.h")
file(REMOVE_RECURSE
    "${SOURCE_PATH}/compat/zlib"
    "${SOURCE_PATH}/libtommath"
    ${sqlite3_sources}
)

if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
    if(VCPKG_TARGET_ARCHITECTURE MATCHES "x64")
        set(TCL_BUILD_MACHINE_STR MACHINE=AMD64)
    elseif(VCPKG_TARGET_ARCHITECTURE MATCHES "arm64")
        set(TCL_BUILD_MACHINE_STR MACHINE=ARM64)
    else()
        set(TCL_BUILD_MACHINE_STR MACHINE=IX86)
    endif()
    
    # Handle features
    set(TCL_BUILD_OPTS OPTS=pdbs)
    set(TCL_BUILD_STATS STATS=none)
    set(TCL_BUILD_CHECKS CHECKS=none)
    if (VCPKG_LIBRARY_LINKAGE STREQUAL static)
        set(TCL_BUILD_OPTS ${TCL_BUILD_OPTS},static,staticpkg)
    endif()
    if (VCPKG_CRT_LINKAGE STREQUAL dynamic)
        set(TCL_BUILD_OPTS ${TCL_BUILD_OPTS},msvcrt)
    endif()
    
    if ("thrdalloc" IN_LIST FEATURES)
        set(TCL_BUILD_OPTS ${TCL_BUILD_OPTS},thrdalloc)
    endif()
    if ("profile" IN_LIST FEATURES)
        set(TCL_BUILD_OPTS ${TCL_BUILD_OPTS},profile)
    endif()
    if ("unchecked" IN_LIST FEATURES)
        set(TCL_BUILD_OPTS ${TCL_BUILD_OPTS},unchecked)
    endif()
    if ("utfmax" IN_LIST FEATURES)
        set(TCL_BUILD_OPTS ${TCL_BUILD_OPTS},time64bit)
    endif()
    
    vcpkg_install_nmake(
        SOURCE_PATH "${SOURCE_PATH}"
        PROJECT_SUBPATH win
        OPTIONS
            ${TCL_BUILD_MACHINE_STR}
            ${TCL_BUILD_STATS}
            ${TCL_BUILD_CHECKS}
            TOMMATHOBJS=tommath.lib
        OPTIONS_DEBUG
            ${TCL_BUILD_OPTS},symbols
            "INSTALLDIR=${CURRENT_PACKAGES_DIR}/debug"
            "SCRIPT_INSTALL_DIR=${CURRENT_PACKAGES_DIR}/tools/tcl/debug/lib/tcl9.0"
            ZLIBOBJS=zd.lib
        OPTIONS_RELEASE
            release
            ${TCL_BUILD_OPTS}
            "INSTALLDIR=${CURRENT_PACKAGES_DIR}"
            "SCRIPT_INSTALL_DIR=${CURRENT_PACKAGES_DIR}/tools/tcl/lib/tcl9.0"
            ZLIBOBJS=zlib
    )

    # Install
    # Note: tcl shell requires it to be in a folder adjacent to the /lib/ folder, i.e. in a /bin/ folder
    if (NOT VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL release)
        file(GLOB_RECURSE TOOL_BIN
                "${CURRENT_PACKAGES_DIR}/bin/*.exe"
                "${CURRENT_PACKAGES_DIR}/bin/*.dll"
        )
        file(COPY ${TOOL_BIN} DESTINATION "${CURRENT_PACKAGES_DIR}/tools/tcl/bin/")

        # Remove .exes only after copying
        file(GLOB_RECURSE TOOL_EXES
                ${CURRENT_PACKAGES_DIR}/bin/*.exe
        )
        file(REMOVE ${TOOL_EXES})

        file(GLOB_RECURSE TOOLS
                "${CURRENT_PACKAGES_DIR}/lib/dde1.4/*"
                "${CURRENT_PACKAGES_DIR}/lib/nmake/*"
                "${CURRENT_PACKAGES_DIR}/lib/reg1.3/*"
                "${CURRENT_PACKAGES_DIR}/lib/tcl8/*"
                "${CURRENT_PACKAGES_DIR}/lib/tcl8.6/*"
                "${CURRENT_PACKAGES_DIR}/lib/tdbcsqlite31.1.0/*"
        )
        
        foreach(TOOL ${TOOLS})
            get_filename_component(DST_DIR ${TOOL} PATH)
            file(COPY "${TOOL}" DESTINATION ${DST_DIR})
        endforeach()
        file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib/dde1.4"
                            "${CURRENT_PACKAGES_DIR}/lib/nmake"
                            "${CURRENT_PACKAGES_DIR}/lib/reg1.3"
                            "${CURRENT_PACKAGES_DIR}/lib/tcl8"
                            "${CURRENT_PACKAGES_DIR}/lib/tcl8.6"
                            "${CURRENT_PACKAGES_DIR}/lib/tdbcsqlite31.1.0"
        )
        file(CHMOD_RECURSE
                "${CURRENT_PACKAGES_DIR}/tools/tcl/lib/tcl9.0/msgs" "${CURRENT_PACKAGES_DIR}/tools/tcl/lib/tcl9.0/tzdata"
            PERMISSIONS
                OWNER_READ OWNER_WRITE
                GROUP_READ GROUP_WRITE
                WORLD_READ WORLD_WRITE
        )
    endif()
    if (NOT VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL debug)
        file(GLOB_RECURSE TOOL_BIN
            "${CURRENT_PACKAGES_DIR}/debug/bin/*.exe"
            "${CURRENT_PACKAGES_DIR}/debug/bin/*.dll"
        )
        file(COPY ${TOOL_BIN} DESTINATION "${CURRENT_PACKAGES_DIR}/tools/tcl/debug/bin/")

        # Remove .exes only after copying
        file(GLOB_RECURSE EXES
                "${CURRENT_PACKAGES_DIR}/debug/bin/*.exe"
        )
        file(REMOVE ${EXES})
    
        file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/lib/dde1.4"
                            "${CURRENT_PACKAGES_DIR}/debug/lib/nmake"
                            "${CURRENT_PACKAGES_DIR}/debug/lib/reg1.3"
                            "${CURRENT_PACKAGES_DIR}/debug/lib/tcl8"
                            "${CURRENT_PACKAGES_DIR}/debug/lib/tcl8.6"
                            "${CURRENT_PACKAGES_DIR}/debug/lib/tdbcsqlite31.1.0"
        )

        file(CHMOD_RECURSE
                "${CURRENT_PACKAGES_DIR}/tools/tcl/debug/lib/tcl9.0/msgs" "${CURRENT_PACKAGES_DIR}/tools/tcl/debug/lib/tcl9.0/tzdata"
            PERMISSIONS
                OWNER_READ OWNER_WRITE
                GROUP_READ GROUP_WRITE
                WORLD_READ WORLD_WRITE
        )
    endif()
    
    if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
        file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
    endif()
    
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
else()
    set(options "")
    if(VCPKG_CROSSCOMPILING)
        vcpkg_host_path_list(PREPEND ENV{PATH} "${CURRENT_HOST_INSTALLED_DIR}/tools/${PORT}/bin")
        set(ENV{HOST_TCLSH} "${CURRENT_HOST_INSTALLED_DIR}/tools/${PORT}/bin/tclsh9.0")
    endif()
    vcpkg_make_configure(
        SOURCE_PATH "${SOURCE_PATH}/unix"
        AUTORECONF
        DEFAULT_OPTIONS_EXCLUDE "^--(disable|enable)-static"
        OPTIONS
            "CFLAGS=-I${CURRENT_INSTALLED_DIR}/include \$CFLAGS"
            ${options}
            --with-system-libtommath
            --with-system-sqlite
    )
    vcpkg_make_install()
    vcpkg_fixup_pkgconfig()
    
    file(GLOB_RECURSE config_scripts "${CURRENT_PACKAGES_DIR}/lib/*Config.sh" "${CURRENT_PACKAGES_DIR}/debug/lib/*Config.sh")
    file(REMOVE ${config_scripts})

    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
endif()
    
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/license.terms")
