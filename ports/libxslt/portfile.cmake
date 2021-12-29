vcpkg_download_distfile(
    PATCH_e2584eed1c84c18f16e42188c30d2c3d8e3e8853
    URLS "https://github.com/GNOME/libxslt/commit/e2584eed1c84c18f16e42188c30d2c3d8e3e8853.patch"
    FILENAME e2584eed1c84c18f16e42188c30d2c3d8e3e8853.patch
    SHA512 d08a06616d732993f2131826ca06fafc2e9f561cb1edb17eaf2adaf78e276bb03cba92a773143eb939da04781f5b5e0a09b351d8e4622a941de3cb3d11da731c
)

# Get this value from configure.ac:21
set(LIBEXSLT_VERSION 0.8.20)
set(VERSION 1.1.34)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO GNOME/libxslt
    REF v${VERSION}
    SHA512 fc57affb236e5f7602ee53c8090a854c6b950d1e6526ae3488bca41d8d421ec70433d88eb227c71c2a61213bc364517bdad907125e36486da1754fe9e460601f
    HEAD_REF master
    PATCHES
        "${PATCH_e2584eed1c84c18f16e42188c30d2c3d8e3e8853}"
        0001-Fix-makefile.patch
        0002-Fix-lzma.patch
        0003-Fix-configure.patch
        only_build_one_lib_type.patch
)

if (VCPKG_TARGET_IS_WINDOWS)
    # Create some directories ourselves, because the makefile doesn't
    file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/bin")
    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
        file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/debug/bin")
    endif()
    set(CONFIGURE_COMMAND_TEMPLATE
        cruntime=@CRUNTIME@
        static=@BUILDSTATIC@
        debug=@DEBUGMODE@
        prefix=@INSTALL_DIR@
        include=@INCLUDE_DIR@
        lib=@LIB_DIR@
        bindir=$(PREFIX)\\bin
        sodir=$(PREFIX)\\bin
        zlib=yes
        lzma=yes
    )

    # Common
    if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
        set(BUILDSTATIC yes)
    else()
        set(BUILDSTATIC no)
    endif()

    # Release params
    if(VCPKG_CRT_LINKAGE STREQUAL dynamic)
        set(CRUNTIME /MD)
    else()
        set(CRUNTIME /MT)
    endif()
    set(DEBUGMODE no)
    set(LIB_DIR "${CURRENT_INSTALLED_DIR}/lib")
    set(INCLUDE_DIR "${CURRENT_INSTALLED_DIR}/include")
    set(INSTALL_DIR "${CURRENT_PACKAGES_DIR}")
    file(TO_NATIVE_PATH "${LIB_DIR}" LIB_DIR)
    file(TO_NATIVE_PATH "${INCLUDE_DIR}" INCLUDE_DIR)
    file(TO_NATIVE_PATH "${INSTALL_DIR}" INSTALL_DIR)
    string(CONFIGURE "${CONFIGURE_COMMAND_TEMPLATE}" CONFIGURE_COMMAND_REL)

    # Debug params
    if(VCPKG_CRT_LINKAGE STREQUAL dynamic)
        set(CRUNTIME /MDd)
    else()
        set(CRUNTIME /MTd)
    endif()
    set(DEBUGMODE yes)
    set(LIB_DIR "${CURRENT_INSTALLED_DIR}/debug/lib")
    set(INSTALL_DIR "${CURRENT_PACKAGES_DIR}/debug")
    file(TO_NATIVE_PATH "${LIB_DIR}" LIB_DIR)
    file(TO_NATIVE_PATH "${INSTALL_DIR}" INSTALL_DIR)
    string(CONFIGURE "${CONFIGURE_COMMAND_TEMPLATE}" CONFIGURE_COMMAND_DBG)

    vcpkg_install_nmake(
        SOURCE_PATH "${SOURCE_PATH}"
        PROJECT_SUBPATH win32
        PROJECT_NAME Makefile.msvc
        PRERUN_SHELL_DEBUG cscript configure.js ${CONFIGURE_COMMAND_DBG}
        PRERUN_SHELL_RELEASE cscript configure.js ${CONFIGURE_COMMAND_REL}
        OPTIONS rebuild
    )

    vcpkg_copy_tools(TOOL_NAMES xsltproc AUTO_CLEAN)

    # The makefile builds both static and dynamic libraries, so remove the ones we don't want
    if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
        file(REMOVE "${CURRENT_PACKAGES_DIR}/lib/libxslt_a${VCPKG_TARGET_STATIC_LIBRARY_SUFFIX}" "${CURRENT_PACKAGES_DIR}/lib/libexslt_a${VCPKG_TARGET_STATIC_LIBRARY_SUFFIX}")
        file(REMOVE "${CURRENT_PACKAGES_DIR}/debug/lib/libxslt_a${VCPKG_TARGET_STATIC_LIBRARY_SUFFIX}" "${CURRENT_PACKAGES_DIR}/debug/lib/libexslt_a${VCPKG_TARGET_STATIC_LIBRARY_SUFFIX}")
    else()
        file(REMOVE "${CURRENT_PACKAGES_DIR}/lib/libxslt${VCPKG_TARGET_STATIC_LIBRARY_SUFFIX}" "${CURRENT_PACKAGES_DIR}/lib/libexslt${VCPKG_TARGET_STATIC_LIBRARY_SUFFIX}")
        file(REMOVE "${CURRENT_PACKAGES_DIR}/debug/lib/libxslt${VCPKG_TARGET_STATIC_LIBRARY_SUFFIX}" "${CURRENT_PACKAGES_DIR}/debug/lib/libexslt${VCPKG_TARGET_STATIC_LIBRARY_SUFFIX}")
        file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
        # Rename the libs to match the dynamic lib names
        file(RENAME "${CURRENT_PACKAGES_DIR}/lib/libxslt_a${VCPKG_TARGET_STATIC_LIBRARY_SUFFIX}" "${CURRENT_PACKAGES_DIR}/lib/libxslt${VCPKG_TARGET_STATIC_LIBRARY_SUFFIX}")
        file(RENAME "${CURRENT_PACKAGES_DIR}/lib/libexslt_a${VCPKG_TARGET_STATIC_LIBRARY_SUFFIX}" "${CURRENT_PACKAGES_DIR}/lib/libexslt${VCPKG_TARGET_STATIC_LIBRARY_SUFFIX}")
        if(NOT VCPKG_BUILD_TYPE)
            file(RENAME "${CURRENT_PACKAGES_DIR}/debug/lib/libxslt_a${VCPKG_TARGET_STATIC_LIBRARY_SUFFIX}" "${CURRENT_PACKAGES_DIR}/debug/lib/libxslt${VCPKG_TARGET_STATIC_LIBRARY_SUFFIX}")
            file(RENAME "${CURRENT_PACKAGES_DIR}/debug/lib/libexslt_a${VCPKG_TARGET_STATIC_LIBRARY_SUFFIX}" "${CURRENT_PACKAGES_DIR}/debug/lib/libexslt${VCPKG_TARGET_STATIC_LIBRARY_SUFFIX}")
        endif()
    endif()

    set(prefix "")
    set(exec_prefix "")
    set(libdir "\${prefix}/lib")
    set(includedir "\${prefix}/include")
    set(XSLT_INCLUDEDIR "-I\${includedir}")
    set(XSLT_LIBDIR "-L\${libdir}")
    set(XSLT_LIBS "-lxslt")
    set(XSLT_PRIVATE_LIBS "")
    set(EXSLT_INCLUDEDIR "-I\${includedir}")
    set(EXSLT_LIBDIR "-L\${libdir}")
    set(EXSLT_LIBS "-lexslt")
    set(EXSLT_PRIVATE_LIBS "")
    file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/lib/pkgconfig")
    configure_file("${SOURCE_PATH}/libxslt.pc.in" "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/libxslt.pc" @ONLY)
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/lib/pkgconfig/libxslt.pc" "\nRequires: " "\nRequires: liblzma ")
    configure_file("${SOURCE_PATH}/libexslt.pc.in" "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/libexslt.pc" @ONLY)
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/lib/pkgconfig/libexslt.pc" "\nRequires: " "\nRequires: libxslt ")
    if(NOT VCPKG_BUILD_TYPE)
        file(COPY "${CURRENT_PACKAGES_DIR}/lib/pkgconfig" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib")
    endif()
else()
    vcpkg_configure_make(
        SOURCE_PATH "${SOURCE_PATH}"
        AUTOCONFIG
        OPTIONS
            --without-python
            --without-plugins
            --with-crypto
        OPTIONS_DEBUG
            --with-mem-debug
            --with-debug
            --with-debugger
    )

    vcpkg_install_make()

    file(REMOVE "${CURRENT_PACKAGES_DIR}/lib/xsltConf.sh" "${CURRENT_PACKAGES_DIR}/debug/lib/xsltConf.sh")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib/libxslt-plugins" "${CURRENT_PACKAGES_DIR}/debug/lib/libxslt-plugins")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/libxslt/aclocal")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/libxslt/doc")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/libxslt/man1")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/libxslt/man3")

    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/tools/libxslt/bin/xslt-config" "${CURRENT_INSTALLED_DIR}" "`dirname $0`/../../../")
    if(NOT VCPKG_BUILD_TYPE)
        vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/tools/libxslt/debug/bin/xslt-config" "${CURRENT_INSTALLED_DIR}" "`dirname $0`/../../../../")
    endif()
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/libxslt/xsltconfig.h" "#define LIBXSLT_DEFAULT_PLUGINS_PATH() \"${CURRENT_INSTALLED_DIR}/lib/libxslt-plugins\"" "")
endif()

vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

#
# Cleanup
#

# You have to define LIB(E)XSLT_STATIC or not, depending on how you link
file(READ "${CURRENT_PACKAGES_DIR}/include/libxslt/xsltexports.h" XSLTEXPORTS_H)
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    string(REPLACE "!defined(LIBXSLT_STATIC)" "0" XSLTEXPORTS_H "${XSLTEXPORTS_H}")
else()
    string(REPLACE "!defined(LIBXSLT_STATIC)" "1" XSLTEXPORTS_H "${XSLTEXPORTS_H}")
endif()
file(WRITE "${CURRENT_PACKAGES_DIR}/include/libxslt/xsltexports.h" "${XSLTEXPORTS_H}")

file(READ "${CURRENT_PACKAGES_DIR}/include/libexslt/exsltexports.h" EXSLTEXPORTS_H)
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    string(REPLACE "!defined(LIBEXSLT_STATIC)" "0" EXSLTEXPORTS_H "${EXSLTEXPORTS_H}")
else()
    string(REPLACE "!defined(LIBEXSLT_STATIC)" "1" EXSLTEXPORTS_H "${EXSLTEXPORTS_H}")
endif()
file(WRITE "${CURRENT_PACKAGES_DIR}/include/libexslt/exsltexports.h" "${EXSLTEXPORTS_H}")

# Remove tools and debug include directories
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL "${SOURCE_PATH}/Copyright" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
