set(PORT_VERSION 14.1)
# NOTE: the python patches must be regenerated on version update

## Download and extract sources
vcpkg_download_distfile(ARCHIVE
    URLS "https://ftp.postgresql.org/pub/source/v${PORT_VERSION}/postgresql-${PORT_VERSION}.tar.bz2"
    FILENAME "postgresql-${PORT_VERSION}.tar.bz2"
    SHA512 4a0bec157d5464bb9e5f5c0eb0efdede55526e03f6f4d660b87d161a47705eb152fa0878960b1581bce42a5ed28a1f457825ea54e8d22e34b5b8eb36473ceefd
)

set(PATCHES
        patches/windows/install.patch
        patches/windows/win_bison_flex.patch
        patches/windows/openssl_exe_path.patch
        patches/windows/Solution.patch
        patches/windows/MSBuildProject_fix_gendef_perl.patch
        patches/windows/msgfmt.patch
        patches/windows/python_lib.patch
        patches/windows/fix-compile-flag-Zi.patch
        patches/windows/tcl_version.patch
        patches/fix-configure.patch        
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
    list(APPEND PATCHES patches/windows/host_skip_openssl.patch) # Skip openssl.exe version check since it cannot be executed by the host
endif()
if(NOT "${FEATURES}" MATCHES "client")
    list(APPEND PATCHES patches/windows/minimize_install.patch)
else()
    set(HAS_TOOLS TRUE)
endif()
vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    PATCHES ${PATCHES}
)
unset(buildenv_contents)
# Get paths to required programs
set(REQUIRED_PROGRAMS PERL)
if(VCPKG_TARGET_IS_WINDOWS)
    list(APPEND REQUIRED_PROGRAMS BISON FLEX)
endif()
foreach(program_name ${REQUIRED_PROGRAMS})
    # Need to rename win_bison and win_flex to just bison and flex
    vcpkg_find_acquire_program(${program_name})
    get_filename_component(${program_name}_EXE_PATH ${${program_name}} DIRECTORY)
    vcpkg_add_to_path(PREPEND "${${program_name}_EXE_PATH}")
    set(buildenv_contents "${buildenv_contents}\n\$ENV{'PATH'}=\$ENV{'PATH'} . ';${${program_name}_EXE_PATH}';")
endforeach()

## Setup build types
if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE MATCHES "[Rr][Ee][Ll][Ee][Aa][Ss][Ee]")
    set(_buildtype RELEASE)
    set(_short rel)
    list(APPEND port_config_list ${_buildtype})
    set(INSTALL_PATH_SUFFIX_${_buildtype} "")
    set(BUILDPATH_${_buildtype} "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${_short}")
    file(REMOVE_RECURSE "${BUILDPATH_${_buildtype}}") #Clean old builds
    set(PACKAGE_DIR_${_buildtype} ${CURRENT_PACKAGES_DIR})
    unset(_short)
    unset(_buildtype)
endif()
if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE MATCHES "[Dd][Ee][Bb][Uu][Gg]")
    set(_buildtype DEBUG)
    set(_short dbg)
    list(APPEND port_config_list ${_buildtype})
    set(INSTALL_PATH_SUFFIX_${_buildtype} "/debug")
    set(BUILDPATH_${_buildtype} "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${_short}")
    file(REMOVE_RECURSE "${BUILDPATH_${_buildtype}}") #Clean old builds
    set(PACKAGE_DIR_${_buildtype} "${CURRENT_PACKAGES_DIR}${INSTALL_PATH_SUFFIX_${_buildtype}}")
    unset(_short)
    unset(_buildtype)
endif()

file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/share/${PORT}")

## Do the build
if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
    file(GLOB SOURCE_FILES ${SOURCE_PATH}/*)
    foreach(_buildtype ${port_config_list})
        # Copy libpq sources.
        message(STATUS "Copying libpq source files to ${BUILDPATH_${_buildtype}}...")
        foreach(SOURCE_FILE ${SOURCE_FILES})
            file(COPY ${SOURCE_FILE} DESTINATION "${BUILDPATH_${_buildtype}}")
        endforeach()
        message(STATUS "Copying libpq source files... done")

        vcpkg_apply_patches(
            SOURCE_PATH "${BUILDPATH_${_buildtype}}"
            PATCHES patches/windows/Solution_${_buildtype}.patch
                    patches/windows/python3_build_${_buildtype}.patch
        )
        message(STATUS "Patches applied!")
        file(COPY "${CURRENT_PORT_DIR}/config.pl" DESTINATION "${BUILDPATH_${_buildtype}}/src/tools/msvc")

        set(MSPROJ_PERL "${BUILDPATH_${_buildtype}}/src/tools/msvc/MSBuildProject.pm")
        file(READ "${MSPROJ_PERL}" _contents)
        string(REPLACE "perl" "\"${PERL}\"" _contents "${_contents}")
        file(WRITE "${MSPROJ_PERL}" "${_contents}")

        set(CONFIG_FILE "${BUILDPATH_${_buildtype}}/src/tools/msvc/config.pl")
        file(READ "${CONFIG_FILE}" _contents)

        ##	ldap      => undef,    # --with-ldap
        ##	extraver  => undef,    # --with-extra-version=<string>
        ##	gss       => undef,    # --with-gssapi=<path>
        ##	icu       => undef,    # --with-icu=<path>                      ##done
        ##	nls       => undef,    # --enable-nls=<path>                    ##done
        ##	tap_tests => undef,    # --enable-tap-tests
        ##	tcl       => undef,    # --with-tcl=<path>                      #done
        ##	perl      => undef,    # --with-perl
        ##	python    => undef,    # --with-python=<path>                   ##done
        ##	openssl   => undef,    # --with-openssl=<path>                  ##done
        ##	uuid      => undef,    # --with-ossp-uuid
        ##	xml       => undef,    # --with-libxml=<path>                   ##done
        ##	xslt      => undef,    # --with-libxslt=<path>                  ##done
        ##	iconv     => undef,    # (not in configure, path to iconv)      ##done (needed by xml)
        ##	zlib      => undef     # --with-zlib=<path>                     ##done

        ## Setup external dependencies
        ##"-DFEATURES=core;openssl;zlib" "-DALL_FEATURES=openssl;zlib;readline;libedit;python;tcl;nls;systemd;llvm;icu;bonjour;uuid;xml;xslt;"
        if("${FEATURES}" MATCHES "icu")
           string(REPLACE "icu       => undef" "icu      => \"${CURRENT_INSTALLED_DIR}\"" _contents "${_contents}")
        endif()
        if("${FEATURES}" MATCHES "nls")
           string(REPLACE "nls       => undef" "nls      => \"${CURRENT_INSTALLED_DIR}\"" _contents "${_contents}")
           vcpkg_acquire_msys(MSYS_ROOT PACKAGES gettext)
           vcpkg_add_to_path("${MSYS_ROOT}/usr/bin")
        endif()
        if("${FEATURES}" MATCHES "openssl")
            set(buildenv_contents "${buildenv_contents}\n\$ENV{'PATH'}=\$ENV{'PATH'} . ';${CURRENT_INSTALLED_DIR}/tools/openssl';")
            #set(_contents "${_contents}\n\$ENV{PATH}=\$ENV{PATH} . ';${CURRENT_INSTALLED_DIR}/tools/openssl';")
            string(REPLACE "openssl   => undef" "openssl   => \"${CURRENT_INSTALLED_DIR}\"" _contents "${_contents}")
        endif()
        if("${FEATURES}" MATCHES "python")
           #vcpkg_find_acquire_program(PYTHON3)
           #get_filename_component(PYTHON3_EXE_PATH ${PYTHON3} DIRECTORY)
           #vcpkg_add_to_path("${PYTHON3_EXE_PATH}")
           string(REPLACE "python    => undef" "python    => \"${CURRENT_INSTALLED_DIR}\"" _contents "${_contents}")
        endif()
        if("${FEATURES}" MATCHES "tcl")
           string(REPLACE "tcl       => undef" "tcl       => \"${CURRENT_INSTALLED_DIR}\"" _contents "${_contents}")
        endif()
        if("${FEATURES}" MATCHES "xml")
           string(REPLACE "xml       => undef" "xml      => \"${CURRENT_INSTALLED_DIR}\"" _contents "${_contents}")
           string(REPLACE "iconv     => undef" "iconv      => \"${CURRENT_INSTALLED_DIR}\"" _contents "${_contents}")
        endif()
        if("${FEATURES}" MATCHES "xslt")
           string(REPLACE "xslt      => undef" "xslt      => \"${CURRENT_INSTALLED_DIR}\"" _contents "${_contents}")
        endif()
        if("${FEATURES}" MATCHES "zlib")
           string(REPLACE "zlib      => undef" "zlib      => \"${CURRENT_INSTALLED_DIR}\"" _contents "${_contents}")
        endif()
        if("${FEATURES}" MATCHES "lz4")
           string(REPLACE "lz4       => undef" "lz4       => \"${CURRENT_INSTALLED_DIR}\"" _contents "${_contents}")
        endif()

        file(WRITE "${CONFIG_FILE}" "${_contents}")
        file(WRITE "${BUILDPATH_${_buildtype}}/src/tools/msvc/buildenv.pl" "${buildenv_contents}")
        vcpkg_get_windows_sdk(VCPKG_TARGET_PLATFORM_VERSION)
        set(ENV{MSBFLAGS} "/p:PlatformToolset=${VCPKG_PLATFORM_TOOLSET}
            /p:VCPkgLocalAppDataDisabled=true
            /p:UseIntelMKL=No
            /p:WindowsTargetPlatformVersion=${VCPKG_TARGET_PLATFORM_VERSION}
            /m
            /p:ForceImportBeforeCppTargets=\"${SCRIPTS}/buildsystems/msbuild/vcpkg.targets\"
            /p:VcpkgTriplet=${TARGET_TRIPLET}
            /p:VcpkgCurrentInstalledDir=\"${CURRENT_INSTALLED_DIR}\""
            )
        if(HAS_TOOLS)
            if(VCPKG_TARGET_ARCHITECTURE STREQUAL x86)
                set(ENV{MSBFLAGS} "$ENV{MSBFLAGS} /p:Platform=Win32")
            endif()
            message(STATUS "Building libpq ${TARGET_TRIPLET}-${_buildtype}...")
            vcpkg_execute_required_process(
                COMMAND ${PERL} build.pl ${_buildtype}
                WORKING_DIRECTORY "${BUILDPATH_${_buildtype}}/src/tools/msvc"
                LOGNAME "build-${TARGET_TRIPLET}-${_buildtype}"
            )
            message(STATUS "Building libpq ${TARGET_TRIPLET}-${_buildtype}... done")
        else()
            set(build_libs libpq libecpg_compat)
            foreach(build_lib ${build_libs})
                message(STATUS "Building ${build_lib} ${TARGET_TRIPLET}-${_buildtype}...")
                vcpkg_execute_required_process(
                    COMMAND ${PERL} build.pl ${_buildtype} ${build_lib}
                    WORKING_DIRECTORY "${BUILDPATH_${_buildtype}}/src/tools/msvc"
                    LOGNAME "build-${build_lib}-${TARGET_TRIPLET}-${_buildtype}"
                )
                message(STATUS "Building ${build_lib} ${TARGET_TRIPLET}-${_buildtype}... done")
            endforeach()
        endif()

        message(STATUS "Installing libpq ${TARGET_TRIPLET}-${_buildtype}...")
        vcpkg_execute_required_process(
            COMMAND ${PERL} install.pl "${CURRENT_PACKAGES_DIR}${INSTALL_PATH_SUFFIX_${_buildtype}}" client
            WORKING_DIRECTORY "${BUILDPATH_${_buildtype}}/src/tools/msvc"
            LOGNAME "install-${TARGET_TRIPLET}-${_buildtype}"
        )
        message(STATUS "Installing libpq ${TARGET_TRIPLET}-${_buildtype}... done")
    endforeach()


    message(STATUS "Cleanup libpq ${TARGET_TRIPLET}...")
    #Cleanup
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/doc")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/tools")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/symbols")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/symbols")

    if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
        file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
    endif()

    if(NOT HAS_TOOLS)
        file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/tools")
    else()
        vcpkg_copy_tool_dependencies("${CURRENT_PACKAGES_DIR}/tools/${PORT}")
    endif()

    message(STATUS "Cleanup libpq ${TARGET_TRIPLET}... - done")
    set(USE_DL OFF)
else()
    file(COPY "${CMAKE_CURRENT_LIST_DIR}/Makefile" DESTINATION "${SOURCE_PATH}")
    
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
    if("zlib" IN_LIST FEATURES)
        list(APPEND BUILD_OPTS --with-zlib)
    else()
        list(APPEND BUILD_OPTS --without-zlib)
    endif()
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
    if("python" IN_LIST FEATURES)
        list(APPEND BUILD_OPTS --with-python)
    else()
        list(APPEND BUILD_OPTS --without-python)
    endif()
    if(VCPKG_TARGET_IS_ANDROID) # AND CMAKE_SYSTEM_VERSION LESS 26)
        list(APPEND BUILD_OPTS ac_cv_header_langinfo_h=no)
    endif()
    if(VCPKG_OSX_SYSROOT)
        list(APPEND BUILD_OPTS "PG_SYSROOT=${VCPKG_OSX_SYSROOT}")
    endif()
    vcpkg_configure_make(
        AUTOCONFIG
        SOURCE_PATH "${SOURCE_PATH}"
        COPY_SOURCE
        DETERMINE_BUILD_TRIPLET
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
        set(ENV{USING_MINGW} yes)
    endif()
    vcpkg_install_make()

    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/bin")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
    if(NOT HAS_TOOLS)
        file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin")
    else()
        vcpkg_copy_tool_dependencies("${CURRENT_PACKAGES_DIR}/tools/${PORT}/bin")
        file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/tools/${PORT}/debug")
    endif()
    if(VCPKG_TARGET_IS_MINGW AND VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
        if (NOT VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
            file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/bin")
            file(RENAME "${CURRENT_PACKAGES_DIR}/lib/libpq.a" "${CURRENT_PACKAGES_DIR}/lib/libpq.dll.a")
            file(RENAME "${CURRENT_PACKAGES_DIR}/lib/libpq.dll" "${CURRENT_PACKAGES_DIR}/bin/libpq.dll")
        endif()
        if (NOT VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
            file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/debug/bin")
            file(RENAME "${CURRENT_PACKAGES_DIR}/debug/lib/libpq.a" "${CURRENT_PACKAGES_DIR}/debug/lib/libpq.dll.a")
            file(RENAME "${CURRENT_PACKAGES_DIR}/debug/lib/libpq.dll" "${CURRENT_PACKAGES_DIR}/debug/bin/libpq.dll")
        endif()
    endif()
    if(VCPKG_TARGET_IS_MINGW)
        set(USE_DL OFF)
    else()
        set(USE_DL ON)
    endif()

    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/postgresql/server/pg_config.h" "#define CONFIGURE_ARGS" "// #define CONFIGURE_ARGS")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/pg_config.h" "#define CONFIGURE_ARGS" "// #define CONFIGURE_ARGS")
endif()

configure_file("${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake" "${CURRENT_PACKAGES_DIR}/share/postgresql/vcpkg-cmake-wrapper.cmake" @ONLY)
file(INSTALL "${CURRENT_PORT_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(INSTALL "${SOURCE_PATH}/COPYRIGHT" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
vcpkg_fixup_pkgconfig()
