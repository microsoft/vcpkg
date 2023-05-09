# NOTE: the python patches must be regenerated on version update
vcpkg_download_distfile(ARCHIVE
    URLS "https://ftp.postgresql.org/pub/source/v${VERSION}/postgresql-${VERSION}.tar.bz2"
    FILENAME "postgresql-${VERSION}.tar.bz2"
    SHA512 115a8a4234791bba4e6dcc4617e9dd77abedcf767894ce9472c59cce9d5d4ef2d4e1746f3a0c7a99de4fc4385fb716652b70dce9f48be45a9db5a682517db7e8
)

set(PATCHES
    patches/windows/install.patch
    patches/windows/win_bison_flex.patch
    patches/windows/openssl-version.patch
    patches/windows/Solution.patch
    patches/windows/MSBuildProject_fix_gendef_perl.patch
    patches/windows/msgfmt.patch
    patches/windows/python_lib.patch
    patches/windows/fix-compile-flag-Zi.patch
    patches/windows/tcl_version.patch
    patches/windows/macro-def.patch
    patches/fix-configure.patch
    patches/no-server-tools.patch
)
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    list(APPEND PATCHES patches/windows/MSBuildProject-static-lib.patch)
    list(APPEND PATCHES patches/windows/Mkvcbuild-static-lib.patch)
endif()
if(VCPKG_CRT_LINKAGE STREQUAL "static")
    list(APPEND PATCHES patches/windows/MSBuildProject-static-crt.patch)
endif()
if(VCPKG_TARGET_ARCHITECTURE MATCHES "arm")
    list(APPEND PATCHES patches/windows/arm.patch)
endif()
if("client" IN_LIST FEATURES)
    set(HAS_TOOLS TRUE)
else()
    set(HAS_TOOLS FALSE)
    list(APPEND PATCHES patches/windows/minimize_install.patch)
endif()
vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    PATCHES ${PATCHES}
)

set(required_programs PERL)
if(VCPKG_TARGET_IS_WINDOWS)
    list(APPEND required_programs BISON FLEX)
endif()
foreach(program_name IN LISTS required_programs)
    # Need to rename win_bison and win_flex to just bison and flex
    vcpkg_find_acquire_program(${program_name})
    get_filename_component(program_dir ${${program_name}} DIRECTORY)
    vcpkg_add_to_path(PREPEND "${program_dir}")
endforeach()

vcpkg_cmake_get_vars(cmake_vars_file)
include("${cmake_vars_file}")

if(VCPKG_DETECTED_MSVC)
    set(config_file "${SOURCE_PATH}/src/tools/msvc/config.pl")
    file(COPY_FILE "${CURRENT_PORT_DIR}/config.pl" "${config_file}")
    file(READ "${config_file}" _contents)
    if("icu" IN_LIST FEATURES)
        string(REPLACE "icu       => undef" "icu      => \"${CURRENT_INSTALLED_DIR}\"" _contents "${_contents}")
    endif()
    if("lz4" IN_LIST FEATURES)
        string(REPLACE "lz4       => undef" "lz4       => \"${CURRENT_INSTALLED_DIR}\"" _contents "${_contents}")
    endif()
    if("nls" IN_LIST FEATURES)
        string(REPLACE "nls       => undef" "nls      => \"${CURRENT_INSTALLED_DIR}\"" _contents "${_contents}")
        vcpkg_acquire_msys(MSYS_ROOT PACKAGES gettext)
        vcpkg_add_to_path("${MSYS_ROOT}/usr/bin")
    endif()
    if("openssl" IN_LIST FEATURES)
        string(REPLACE "openssl   => undef" "openssl   => \"${CURRENT_INSTALLED_DIR}\"" _contents "${_contents}")
    endif()
    if("python" IN_LIST FEATURES)
        #vcpkg_find_acquire_program(PYTHON3)
        #get_filename_component(PYTHON3_EXE_PATH ${PYTHON3} DIRECTORY)
        #vcpkg_add_to_path("${PYTHON3_EXE_PATH}")
        string(REPLACE "python    => undef" "python    => \"${CURRENT_INSTALLED_DIR}\"" _contents "${_contents}")
    endif()
    if("tcl" IN_LIST FEATURES)
        string(REPLACE "tcl       => undef" "tcl       => \"${CURRENT_INSTALLED_DIR}\"" _contents "${_contents}")
    endif()
    if("xml" IN_LIST FEATURES)
        string(REPLACE "xml       => undef" "xml       => \"${CURRENT_INSTALLED_DIR}\"" _contents "${_contents}")
        string(REPLACE "iconv     => undef" "iconv     => \"${CURRENT_INSTALLED_DIR}\"" _contents "${_contents}")
    endif()
    if("xslt" IN_LIST FEATURES)
        string(REPLACE "xslt      => undef" "xslt      => \"${CURRENT_INSTALLED_DIR}\"" _contents "${_contents}")
    endif()
    if("zlib" IN_LIST FEATURES)
        string(REPLACE "zlib      => undef" "zlib      => \"${CURRENT_INSTALLED_DIR}\"" _contents "${_contents}")
    endif()
    if("zstd" IN_LIST FEATURES)
        string(REPLACE "zstd      => undef" "zstd      => \"${CURRENT_INSTALLED_DIR}\"" _contents "${_contents}")
    endif()
    file(WRITE "${config_file}" "${_contents}")

    configure_file("${CURRENT_PORT_DIR}/libpq.props.in" "${SOURCE_PATH}/libpq.props" @ONLY)
    vcpkg_replace_string("${SOURCE_PATH}/src/tools/msvc/MSBuildProject.pm" "perl" "\"${PERL}\"")

    if("openssl" IN_LIST FEATURES)
        file(STRINGS "${CURRENT_INSTALLED_DIR}/lib/pkgconfig/openssl.pc" OPENSSL_VERSION REGEX "Version:")
        if(OPENSSL_VERSION)
            set(ENV{VCPKG_OPENSSL_VERSION} "${OPENSSL_VERSION}")
        endif()
    endif()

    include("${CMAKE_CURRENT_LIST_DIR}/build-msvc.cmake")
    if(NOT VCPKG_BUILD_TYPE)
        build_msvc(DEBUG "${SOURCE_PATH}")
    endif()
    build_msvc(RELEASE "${SOURCE_PATH}")

    if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
        file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
    endif()

    if(HAS_TOOLS)
        vcpkg_copy_tool_dependencies("${CURRENT_PACKAGES_DIR}/tools/${PORT}")
    else()
        file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/tools")
    endif()
else()
    file(COPY "${CMAKE_CURRENT_LIST_DIR}/Makefile" DESTINATION "${SOURCE_PATH}")
    
    if("icu" IN_LIST FEATURES)
        list(APPEND BUILD_OPTS --with-icu)
    else()
        list(APPEND BUILD_OPTS --without-icu)
    endif()
    if("lz4" IN_LIST FEATURES)
        list(APPEND BUILD_OPTS --with-lz4)
    else()
        list(APPEND BUILD_OPTS --without-lz4)
    endif()
    if("nls" IN_LIST FEATURES)
        list(APPEND BUILD_OPTS --enable-nls)
        set(ENV{MSGFMT} "${CURRENT_HOST_INSTALLED_DIR}/tools/gettext/bin/msgfmt${VCPKG_HOST_EXECUTABLE_SUFFIX}")
    else()
        list(APPEND BUILD_OPTS --disable-nls)
    endif()
    if("openssl" IN_LIST FEATURES)
        list(APPEND BUILD_OPTS --with-openssl)
    else()
        list(APPEND BUILD_OPTS --without-openssl)
    endif()
    if("python" IN_LIST FEATURES)
        list(APPEND BUILD_OPTS --with-python)
    else()
        list(APPEND BUILD_OPTS --without-python)
    endif()
    if("readline" IN_LIST FEATURES)
        list(APPEND BUILD_OPTS --with-readline)
    else()
        list(APPEND BUILD_OPTS --without-readline)
    endif()
    if("xml" IN_LIST FEATURES)
        list(APPEND BUILD_OPTS --with-libxml)
    else()
        list(APPEND BUILD_OPTS --without-libxml)
    endif()
    if("xslt" IN_LIST FEATURES)
        list(APPEND BUILD_OPTS --with-libxslt)
    else()
        list(APPEND BUILD_OPTS --without-libxslt)
    endif()
    if("zlib" IN_LIST FEATURES)
        list(APPEND BUILD_OPTS --with-zlib)
    else()
        list(APPEND BUILD_OPTS --without-zlib)
    endif()
    if("zstd" IN_LIST FEATURES)
        list(APPEND BUILD_OPTS --with-zstd)
    else()
        list(APPEND BUILD_OPTS --without-zstd)
    endif()
    if(VCPKG_TARGET_IS_ANDROID) # AND CMAKE_SYSTEM_VERSION LESS 26)
        list(APPEND BUILD_OPTS ac_cv_header_langinfo_h=no)
    endif()
    if(VCPKG_DETECTED_CMAKE_OSX_SYSROOT)
        list(APPEND BUILD_OPTS "PG_SYSROOT=${VCPKG_DETECTED_CMAKE_OSX_SYSROOT}")
    endif()
    vcpkg_configure_make(
        SOURCE_PATH "${SOURCE_PATH}"
        COPY_SOURCE
        DETERMINE_BUILD_TRIPLET
        AUTOCONFIG
        ADDITIONAL_MSYS_PACKAGES autoconf-archive
            DIRECT_PACKAGES
                "https://mirror.msys2.org/msys/x86_64/tzcode-2023c-1-x86_64.pkg.tar.zst"
                7550b843964744607f736a7138f10c6cd92489406a1b84ac71d9a9d8aa16bc69048aa1b24e1f49291b010347047008194c334ca9c632e17fa8245e85549e3c7a
        OPTIONS
            ${BUILD_OPTS}
        OPTIONS_DEBUG
            --enable-debug
    )

    if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
        set(ENV{LIBPQ_LIBRARY_TYPE} shared)
    else()
        set(ENV{LIBPQ_LIBRARY_TYPE} static)
    endif()
    if(VCPKG_TARGET_IS_MINGW)
        set(ENV{LIBPQ_USING_MINGW} yes)
    endif()
    if(HAS_TOOLS)
        set(ENV{LIBPQ_ENABLE_TOOLS} yes)
    endif()
    vcpkg_install_make()

    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/bin")
    if(HAS_TOOLS)
        file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin")
    endif()
    if(VCPKG_TARGET_IS_MINGW AND VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
        file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/bin")
        file(RENAME "${CURRENT_PACKAGES_DIR}/lib/libpq.a" "${CURRENT_PACKAGES_DIR}/lib/libpq.dll.a")
        file(RENAME "${CURRENT_PACKAGES_DIR}/lib/libpq.dll" "${CURRENT_PACKAGES_DIR}/bin/libpq.dll")
        if (NOT VCPKG_BUILD_TYPE)
            file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/debug/bin")
            file(RENAME "${CURRENT_PACKAGES_DIR}/debug/lib/libpq.a" "${CURRENT_PACKAGES_DIR}/debug/lib/libpq.dll.a")
            file(RENAME "${CURRENT_PACKAGES_DIR}/debug/lib/libpq.dll" "${CURRENT_PACKAGES_DIR}/debug/bin/libpq.dll")
        endif()
    endif()

    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/postgresql/server/pg_config.h" "#define CONFIGURE_ARGS" "// #define CONFIGURE_ARGS")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/pg_config.h" "#define CONFIGURE_ARGS" "// #define CONFIGURE_ARGS")
endif()

vcpkg_fixup_pkgconfig()
configure_file("${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake" "${CURRENT_PACKAGES_DIR}/share/postgresql/vcpkg-cmake-wrapper.cmake" @ONLY)

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/doc"
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
    "${CURRENT_PACKAGES_DIR}/debug/symbols"
    "${CURRENT_PACKAGES_DIR}/debug/tools"
    "${CURRENT_PACKAGES_DIR}/symbols"
    "${CURRENT_PACKAGES_DIR}/tools/${PORT}/debug"
)

file(INSTALL "${CURRENT_PORT_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYRIGHT")
