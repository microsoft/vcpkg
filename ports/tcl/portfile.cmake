vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO tcltk/tcl
    REF 590390207d727708be57b4908eb24dbe705d090c
    SHA512 4a4cc54bd3b8f498af4bc62733ca4b101482548b9aa6d1052f05523231bdb5a09d148be083404f468d1b90a71e5490c6a693c13fbcbcf5a0e106086f85a0df0b
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
            SCRIPT_INSTALL_DIR=${CURRENT_PACKAGES_DIR}/tools/tcl/debug/lib/tcl8.6
        OPTIONS_RELEASE
            release
            ${TCL_BUILD_OPTS}
            INSTALLDIR=${CURRENT_PACKAGES_DIR}
            SCRIPT_INSTALL_DIR=${CURRENT_PACKAGES_DIR}/tools/tcl/lib/tcl8.6
    )


    # Install
    # Note: tcl shell requires it to be in a folder adjacent to the /lib/ folder, i.e. in a /bin/ folder
    if (NOT VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL release)
        file(GLOB_RECURSE TOOL_BIN
                ${CURRENT_PACKAGES_DIR}/bin/*.exe
                ${CURRENT_PACKAGES_DIR}/bin/*.dll
        )
        file(COPY ${TOOL_BIN} DESTINATION ${CURRENT_PACKAGES_DIR}/tools/tcl/bin/)

        # Remove .exes only after copying
        file(GLOB_RECURSE TOOL_EXES
                ${CURRENT_PACKAGES_DIR}/bin/*.exe
        )
        file(REMOVE ${TOOL_EXES})

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
            file(COPY ${TOOL} DESTINATION ${DST_DIR})
        endforeach()
        file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib/dde1.4
                            ${CURRENT_PACKAGES_DIR}/lib/nmake
                            ${CURRENT_PACKAGES_DIR}/lib/reg1.3
                            ${CURRENT_PACKAGES_DIR}/lib/tcl8
                            ${CURRENT_PACKAGES_DIR}/lib/tcl8.6
                            ${CURRENT_PACKAGES_DIR}/lib/tdbcsqlite31.1.0
        )
    endif()
    if (NOT VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL debug)
        file(GLOB_RECURSE TOOL_BIN
            ${CURRENT_PACKAGES_DIR}/debug/bin/*.exe
            ${CURRENT_PACKAGES_DIR}/debug/bin/*.dll
        )
        file(COPY ${TOOL_BIN} DESTINATION ${CURRENT_PACKAGES_DIR}/tools/tcl/debug/bin/)

        # Remove .exes only after copying
        file(GLOB_RECURSE EXES
                ${CURRENT_PACKAGES_DIR}/debug/bin/*.exe
        )
        file(REMOVE ${EXES})
    
        file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/lib/dde1.4
                            ${CURRENT_PACKAGES_DIR}/debug/lib/nmake
                            ${CURRENT_PACKAGES_DIR}/debug/lib/reg1.3
                            ${CURRENT_PACKAGES_DIR}/debug/lib/tcl8
                            ${CURRENT_PACKAGES_DIR}/debug/lib/tcl8.6
                            ${CURRENT_PACKAGES_DIR}/debug/lib/tdbcsqlite31.1.0
        )
    endif()
    
    if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
        file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
    endif()
    
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
    
else()
    vcpkg_configure_make(
        SOURCE_PATH ${SOURCE_PATH}
        PROJECT_SUBPATH unix
        NO_ADDITIONAL_PATHS
    )
    
    vcpkg_install_make()
    vcpkg_fixup_pkgconfig()
    
    if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
        file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
    endif()
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include ${CURRENT_PACKAGES_DIR}/debug/share)
endif()

file(INSTALL ${SOURCE_PATH}/license.terms DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
