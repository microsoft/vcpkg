vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO tcltk/tcl
    REF 0cb9c0b3f8c6426be5bf4b609aef819e379d123e
    SHA512 5a4e293d8d741148674e67de3a10f94f8b812d2dd4a36ef9a3e2a64eb8b4e21c0a31649cf95bdb76290243f14c8b61982a1f28a71d5def771312543f595bba6f
    PATCHES
        force-shell-install.patch
        remove-git-rev-parse.patch
)

if (VCPKG_TARGET_IS_WINDOWS)
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
                "${CURRENT_PACKAGES_DIR}/lib/registry1.3/*"
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
                            "${CURRENT_PACKAGES_DIR}/lib/registry1.3"
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
                            "${CURRENT_PACKAGES_DIR}/debug/lib/registry1.3"
        )
    endif()
    
    if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
        file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
    endif()
    
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
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

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/license.terms")
