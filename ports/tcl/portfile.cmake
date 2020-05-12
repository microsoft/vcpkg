vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO tcltk/tcl
    REF 2abfa2c03ddc0419e6525f86c2c0323b2ba1932e
    SHA512 d9bc83c389cf3b95ab64b75c57eb9a2b23b957503d2dadc2d3f6854e9e784d87d9b2059a82f35accb419693bfe675b523c4751af91efac700644e118ff689fd7)

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
            ${TCL_BUILD_OPTS}
            release
            INSTALLDIR=${CURRENT_PACKAGES_DIR}
            SCRIPT_INSTALL_DIR=${CURRENT_PACKAGES_DIR}/tools/tcl/lib/tcl9.0
    )
    # Install
    if (NOT VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL release)
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