
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO GNOME/libxslt
    REF  v1.1.33
    SHA512 2c20b2af3c19952b25b10dca0d95fe227602f7f815db352b04dd061c52c458d745f92c597ce08ac9207ba0fbe0169ea2fb78263d8590743717553f84463fe1d9
    HEAD_REF master
    PATCHES
        0001-Fix-makefile.patch
        0002-Fix-lzma.patch
)

if (VCPKG_TARGET_IS_WINDOWS)
    # Create some directories ourselves, because the makefile doesn't
    file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/bin)
    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
        file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/debug/bin)
    endif()
    set(CONFIGURE_COMMAND_TEMPLATE
        cruntime=@CRUNTIME@
        debug=@DEBUGMODE@
        prefix=@INSTALL_DIR@
        include=@INCLUDE_DIR@
        lib=@LIB_DIR@
        bindir=$(PREFIX)\\tools\\${PORT}
        sodir=$(PREFIX)\\bin\\
    )
    # Debug params
    if(VCPKG_CRT_LINKAGE STREQUAL dynamic)
        set(CRUNTIME /MD)
    else()
        set(CRUNTIME /MT)
    endif()
    set(DEBUGMODE no)
    set(LIB_DIR ${CURRENT_INSTALLED_DIR}/lib)
    set(INCLUDE_DIR ${CURRENT_INSTALLED_DIR}/include)
    set(INSTALL_DIR ${CURRENT_PACKAGES_DIR})
    file(TO_NATIVE_PATH "${LIB_DIR}" LIB_DIR)
    file(TO_NATIVE_PATH "${INCLUDE_DIR}" INCLUDE_DIR)
    file(TO_NATIVE_PATH "${INSTALL_DIR}" INSTALL_DIR)
    string(CONFIGURE "${CONFIGURE_COMMAND_TEMPLATE}" CONFIGURE_COMMAND_REL)
    # Release params
    if(VCPKG_CRT_LINKAGE STREQUAL dynamic)
        set(CRUNTIME /MDd)
    else()
        set(CRUNTIME /MTd)
    endif()
    set(DEBUGMODE yes)
    set(LIB_DIR ${CURRENT_INSTALLED_DIR}/debug/lib)
    set(INSTALL_DIR ${CURRENT_PACKAGES_DIR}/debug)
    file(TO_NATIVE_PATH "${LIB_DIR}" LIB_DIR)
    file(TO_NATIVE_PATH "${INSTALL_DIR}" INSTALL_DIR)
    string(CONFIGURE "${CONFIGURE_COMMAND_TEMPLATE}" CONFIGURE_COMMAND_DBG)
    
    vcpkg_install_nmake(
        SOURCE_PATH ${SOURCE_PATH}
        PROJECT_SUBPATH win32
        PROJECT_NAME Makefile.msvc
        PRERUN_SHELL_DEBUG cscript configure.js ${CONFIGURE_COMMAND_DBG}
        PRERUN_SHELL_RELEASE cscript configure.js ${CONFIGURE_COMMAND_REL}
        OPTIONS rebuild
    )
    
    # The makefile builds both static and dynamic libraries, so remove the ones we don't want
    if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
        file(REMOVE ${CURRENT_PACKAGES_DIR}/lib/libxslt_a${VCPKG_TARGET_STATIC_LIBRARY_SUFFIX} ${CURRENT_PACKAGES_DIR}/lib/libexslt_a${VCPKG_TARGET_STATIC_LIBRARY_SUFFIX})
        file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/lib/libxslt_a${VCPKG_TARGET_STATIC_LIBRARY_SUFFIX} ${CURRENT_PACKAGES_DIR}/debug/lib/libexslt_a${VCPKG_TARGET_STATIC_LIBRARY_SUFFIX})
    else()
        file(REMOVE ${CURRENT_PACKAGES_DIR}/lib/libxslt${VCPKG_TARGET_STATIC_LIBRARY_SUFFIX} ${CURRENT_PACKAGES_DIR}/lib/libexslt${VCPKG_TARGET_STATIC_LIBRARY_SUFFIX})
        file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/lib/libxslt${VCPKG_TARGET_STATIC_LIBRARY_SUFFIX} ${CURRENT_PACKAGES_DIR}/debug/lib/libexslt${VCPKG_TARGET_STATIC_LIBRARY_SUFFIX})
        file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
        # Rename the libs to match the dynamic lib names
        file(RENAME ${CURRENT_PACKAGES_DIR}/lib/libxslt_a${VCPKG_TARGET_STATIC_LIBRARY_SUFFIX} ${CURRENT_PACKAGES_DIR}/lib/libxslt${VCPKG_TARGET_STATIC_LIBRARY_SUFFIX})
        file(RENAME ${CURRENT_PACKAGES_DIR}/lib/libexslt_a${VCPKG_TARGET_STATIC_LIBRARY_SUFFIX} ${CURRENT_PACKAGES_DIR}/lib/libexslt${VCPKG_TARGET_STATIC_LIBRARY_SUFFIX})
        file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/libxslt_a${VCPKG_TARGET_STATIC_LIBRARY_SUFFIX} ${CURRENT_PACKAGES_DIR}/debug/lib/libxslt${VCPKG_TARGET_STATIC_LIBRARY_SUFFIX})
        file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/libexslt_a${VCPKG_TARGET_STATIC_LIBRARY_SUFFIX} ${CURRENT_PACKAGES_DIR}/debug/lib/libexslt${VCPKG_TARGET_STATIC_LIBRARY_SUFFIX})
    endif()
else()
    vcpkg_find_acquire_program(PYTHON3)
    get_filename_component(PYTHON3_DIR ${PYTHON3} DIRECTORY)
    
    find_library(LibXml2_DEBUG_LIBRARIES libxml2 PATHS ${CURRENT_INSTALLED_DIR}/debug/lib REQUIRED)
    find_library(LibXml2_RELEASE_LIBRARIES libxml2 PATHS ${CURRENT_INSTALLED_DIR}/lib REQUIRED)
    
    vcpkg_configure_make(
        SOURCE_PATH ${SOURCE_PATH}
        AUTOCONFIG
        OPTIONS
            --with-crypto
            --with-plugins
            --with-libxml-include-prefix=${CURRENT_INSTALLED_DIR}/include
            --with-python=${PYTHON3_DIR}
        OPTIONS_DEBUG
            --with-mem-debug
            --with-debug
            --with-debugger
            --with-libxml-libs-prefix="${CURRENT_INSTALLED_DIR}/debug/lib -lxml2 -lz -llzmad"
            --with-html-dir=${CURRENT_INSTALLED_DIR}/debug/tools
            --with-html-subdir=${CURRENT_INSTALLED_DIR}/debug/tools
        OPTIONS_RELEASE
            --with-libxml-libs-prefix="${CURRENT_INSTALLED_DIR}/lib -lxml2 -lz -llzma"
            --with-html-dir=${CURRENT_INSTALLED_DIR}/tools
            --with-html-subdir=${CURRENT_INSTALLED_DIR}/tools
    )
    
    vcpkg_install_make()
    #vcpkg_fixup_pkgconfig()?
    
    if (EXISTS ${CURRENT_PACKAGES_DIR}/bin/xslt-config)
        file(COPY ${CURRENT_PACKAGES_DIR}/bin/xslt-config DESTINATION ${CURRENT_PACKAGES_DIR}/tools)
        file(REMOVE ${CURRENT_PACKAGES_DIR}/bin/xslt-config)
    endif()
    if (EXISTS ${CURRENT_PACKAGES_DIR}/bin/xsltproc)
        file(COPY ${CURRENT_PACKAGES_DIR}/bin/xsltproc DESTINATION ${CURRENT_PACKAGES_DIR}/tools)
        file(REMOVE ${CURRENT_PACKAGES_DIR}/bin/xslt-config)
    endif()
    if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
        file(COPY ${CURRENT_PACKAGES_DIR}/lib/libxslt.so ${CURRENT_PACKAGES_DIR}/bin/)
    else()
        file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
        file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib/libxslt-plugins ${CURRENT_PACKAGES_DIR}/debug/lib/libxslt-plugins)
    endif()
    file(REMOVE ${CURRENT_PACKAGES_DIR}/lib/libxslt.so)
    file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools/${PORT}")
    file(RENAME "${CURRENT_PACKAGES_DIR}/tools/xsltproc" "${CURRENT_PACKAGES_DIR}/tools/${PORT}/xsltproc")
endif()
#
# Cleanup
#

# You have to define LIB(E)XSLT_STATIC or not, depending on how you link
file(READ ${CURRENT_PACKAGES_DIR}/include/libxslt/xsltexports.h XSLTEXPORTS_H)
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    string(REPLACE "!defined(LIBXSLT_STATIC)" "0" XSLTEXPORTS_H "${XSLTEXPORTS_H}")
else()
    string(REPLACE "!defined(LIBXSLT_STATIC)" "1" XSLTEXPORTS_H "${XSLTEXPORTS_H}")
endif()
file(WRITE ${CURRENT_PACKAGES_DIR}/include/libxslt/xsltexports.h "${XSLTEXPORTS_H}")

file(READ ${CURRENT_PACKAGES_DIR}/include/libexslt/exsltexports.h EXSLTEXPORTS_H)
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    string(REPLACE "!defined(LIBEXSLT_STATIC)" "0" EXSLTEXPORTS_H "${EXSLTEXPORTS_H}")
else()
    string(REPLACE "!defined(LIBEXSLT_STATIC)" "1" EXSLTEXPORTS_H "${EXSLTEXPORTS_H}")
endif()
file(WRITE ${CURRENT_PACKAGES_DIR}/include/libexslt/exsltexports.h "${EXSLTEXPORTS_H}")

# Remove tools and debug include directories
#file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/tools)
vcpkg_copy_tool_dependencies("${CURRENT_PACKAGES_DIR}/tools/${PORT}")
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/tools)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
    vcpkg_copy_pdbs()
endif()

file(INSTALL ${SOURCE_PATH}/Copyright DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

