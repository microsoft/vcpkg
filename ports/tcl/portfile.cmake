vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO tcltk/tcl
    REF 0fa6a4e5aad821a5c34fdfa070c37c3f1ffc8c8e
    SHA512 9d7f35309fe8b1a7c116639aaea50cc01699787c7afb432389bee2b9ad56a67034c45d90c9585ef1ccf15bdabf0951cbef86257c0c6aedbd2591bbfae3e93b76
    PATCHES force-shell-install.patch
)

if (VCPKG_TARGET_IS_WINDOWS)
    if(VCPKG_TARGET_ARCHITECTURE MATCHES "x64")
        set(TCL_BUILD_MACHINE_STR MACHINE=AMD64)
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
        SOURCE_PATH ${SOURCE_PATH}
        PROJECT_SUBPATH win
        OPTIONS
            ${TCL_BUILD_MACHINE_STR}
            ${TCL_BUILD_STATS}
            ${TCL_BUILD_CHECKS}
        OPTIONS_DEBUG
            ${TCL_BUILD_OPTS},symbols
            INSTALLDIR=${CURRENT_PACKAGES_DIR}/debug
            SCRIPT_INSTALL_DIR=${CURRENT_PACKAGES_DIR}/tools/tcl/debug/lib/tcl9.0
        OPTIONS_RELEASE
            release
            ${TCL_BUILD_OPTS}
            INSTALLDIR=${CURRENT_PACKAGES_DIR}
            SCRIPT_INSTALL_DIR=${CURRENT_PACKAGES_DIR}/tools/tcl/lib/tcl9.0
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
    endif()
    
    if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
        file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
    endif()
    
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
    
    file(CHMOD_RECURSE
            "${CURRENT_PACKAGES_DIR}/tools/tcl/debug/lib/tcl9.0/msgs" "${CURRENT_PACKAGES_DIR}/tools/tcl/debug/lib/tcl9.0/tzdata"
            "${CURRENT_PACKAGES_DIR}/tools/tcl/lib/tcl9.0/msgs" "${CURRENT_PACKAGES_DIR}/tools/tcl/lib/tcl9.0/tzdata"
        PERMISSIONS
            OWNER_READ OWNER_WRITE
            GROUP_READ GROUP_WRITE
            WORLD_READ WORLD_WRITE
    )
else()
    file(REMOVE "${SOURCE_PATH}/unix/configure")
    vcpkg_configure_make(
        SOURCE_PATH "${SOURCE_PATH}"
        PROJECT_SUBPATH unix
    )
    
    vcpkg_install_make()
    vcpkg_fixup_pkgconfig()
    
    if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
        file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
    endif()
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")
endif()
    
file(REMOVE "${CURRENT_PACKAGES_DIR}/lib/tclConfig.sh" "${CURRENT_PACKAGES_DIR}/debug/lib/tclConfig.sh")

file(INSTALL "${SOURCE_PATH}/license.terms" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
