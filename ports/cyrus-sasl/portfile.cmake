# NOTE: We don't use vcpkg_from_github as it does not
# include all the necessary source files
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/cyrusimap/cyrus-sasl/releases/download/cyrus-sasl-${VERSION}/cyrus-sasl-${VERSION}.tar.gz"
    FILENAME "cyrus-sasl-${VERSION}.tar.gz"
    SHA512 db15af9079758a9f385457a79390c8a7cd7ea666573dace8bf4fb01bb4b49037538d67285727d6a70ad799d2e2318f265c9372e2427de9371d626a1959dd6f78
)
vcpkg_extract_source_archive(SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    PATCHES
        configure.diff
        fix-gcc14-time-includes.diff
)

if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
    file(REMOVE "${SOURCE_PATH}/include/md5global.h")
    file(COPY "${SOURCE_PATH}/win32/include/md5global.h" DESTINATION "${SOURCE_PATH}/include/md5global.h")

    vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY) # only DLL build rules

    set(STATIC_CRT_LINKAGE no)
    if(VCPKG_CRT_LINKAGE STREQUAL "static")
        set(STATIC_CRT_LINKAGE yes)
    endif()

    string(APPEND VCPKG_C_FLAGS " /DUNICODE /D_UNICODE /D_WINSOCK_DEPRECATED_NO_WARNINGS")
    string(APPEND VCPKG_CXX_FLAGS " /DUNICODE /D_UNICODE /D_WINSOCK_DEPRECATED_NO_WARNINGS")

    cmake_path(NATIVE_PATH CURRENT_INSTALLED_DIR CURRENT_INSTALLED_DIR_NATIVE)
    cmake_path(NATIVE_PATH CURRENT_PACKAGES_DIR CURRENT_PACKAGES_DIR_NATIVE)
    vcpkg_install_nmake(
        SOURCE_PATH "${SOURCE_PATH}"
        PROJECT_NAME "NTMakefile"
        OPTIONS
            STATIC=${STATIC_CRT_LINKAGE}
            "SUBDIRS=lib plugins utils"
            # Note https://www.cyrusimap.org/sasl/sasl/windows.html#limitations
            GSSAPI=MITKerberos    # but "GSSAPI - tested using CyberSafe"
            "GSSAPI_INCLUDE=${CURRENT_INSTALLED_DIR_NATIVE}\\include"
            SASLDB=LMDB           # but "SASLDB - only SleepyCat version can be built"
            "LMDB_INCLUDE=${CURRENT_INSTALLED_DIR_NATIVE}\\include"
            SRP=1
            DO_SRP_SETPASS=1
            OTP=1
            "OPENSSL_INCLUDE=${CURRENT_INSTALLED_DIR_NATIVE}\\include"
            # Silence log messages about default initialization
            "DB_LIB=unused"
            "DB_INCLUDE=${CURRENT_PACKAGES_DIR_NATIVE}\\unused"
            "DB_LIBPATH=${CURRENT_PACKAGES_DIR_NATIVE}\\unused"
            "LDAP_INCLUDE=${CURRENT_PACKAGES_DIR_NATIVE}\\unused"
            "LDAP_LIB_BASE=${CURRENT_PACKAGES_DIR_NATIVE}\\unused"
            "SQLITE_INCLUDE=${CURRENT_PACKAGES_DIR_NATIVE}\\unused"
            "SQLITE_LIBPATH=${CURRENT_PACKAGES_DIR_NATIVE}\\unused"
            "SQLITE_INCLUDE3=${CURRENT_PACKAGES_DIR_NATIVE}\\unused"
            "SQLITE_LIBPATH3=${CURRENT_PACKAGES_DIR_NATIVE}\\unused"
        OPTIONS_RELEASE
            CFG=Release
            "prefix=${CURRENT_PACKAGES_DIR_NATIVE}"
            "GSSAPI_LIBPATH=${CURRENT_INSTALLED_DIR_NATIVE}\\lib"
            "LMDB_LIBPATH=${CURRENT_INSTALLED_DIR_NATIVE}\\lib"
            "OPENSSL_LIBPATH=${CURRENT_INSTALLED_DIR_NATIVE}\\lib"
        OPTIONS_DEBUG
            CFG=Debug
            "prefix=${CURRENT_PACKAGES_DIR_NATIVE}\\debug"
            "GSSAPI_LIBPATH=${CURRENT_INSTALLED_DIR_NATIVE}\\debug\\lib"
            "LMDB_LIBPATH=${CURRENT_INSTALLED_DIR_NATIVE}\\debug\\lib"
            "OPENSSL_LIBPATH=${CURRENT_INSTALLED_DIR_NATIVE}\\debug\\lib"
    )
    vcpkg_copy_tools(TOOL_NAMES pluginviewer sasldblistusers2 saslpasswd2 testsuite AUTO_CLEAN)

    block(SCOPE_FOR VARIABLES)
        set(prefix      [[placeholder]])
        set(exec_prefix [[${prefix}]])
        set(libdir      [[${prefix}/lib]])
        set(includedir  [[${prefix}/include]])
        configure_file("${SOURCE_PATH}/libsasl2.pc.in" "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/libsasl2.pc" @ONLY)
        vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/lib/pkgconfig/libsasl2.pc" " -lsasl2" " -llibsasl")
        if(NOT VCPKG_BUILD_TYPE)
            file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig")
            file(COPY_FILE "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/libsasl2.pc" "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/libsasl2.pc")
        endif()
    endblock()

else()
    vcpkg_find_acquire_program(PKGCONFIG)
    set(ENV{PKG_CONFIG} "${PKGCONFIG}")

    vcpkg_configure_make(
        SOURCE_PATH "${SOURCE_PATH}"
        AUTOCONFIG
        OPTIONS
            --enable-sample=no
            --with-dblib=lmdb
            --with-gss_impl=mit
            --disable-macos-framework
    )
    vcpkg_install_make()
endif()

vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING"
    COMMENT [[
The top-level COPYING file represents the license identified as BSD with
Attribution and HPND disclaimer. However, various source files are under
different licenses, including other BSD license variants, MIT license
variants, OpenLDAP, OpenSSL and others.
]])
