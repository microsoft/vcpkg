if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    message(FATAL_ERROR "${PORT} currently only supports being built for desktop")
endif()

#vcpkg_get_build_depends(OUTPUT_VARIABLE TEST_VAR PORT zlib FEATURES core)
#message(STATUS "TEST_VAR:${TEST_VAR}")
#if("${TEST_VAR}" MATCHES "")
#    message(STATUS "EMPTY DEPENDENCY")
#endif()

vcpkg_read_dependent_port_info()
message(STATUS "${PORT}_ALL_DEPENDENCIES: ${${PORT}_ALL_DEPENDENCIES}")

if(VCPKG_TARGET_IS_OSX AND NOT "${FEATURES}" MATCHES "bonjour")
    message(STATUS "Feature bonjour not used. On OsX building with feature bonjour is recommended")
    ## OPTIONS 
endif()

if("${FEATURES}" MATCHES "readline|libedit|perl|python|tcl|nls|kerberos|systemd|ldap|bsd|pam|llvm|icu|uuid|xml|xslt")
   # message(FATAL_ERROR "These features are TODOs. If you require them feel free to implement them")
endif()

## Download and extract sources
vcpkg_download_distfile(ARCHIVE
    URLS "https://ftp.postgresql.org/pub/source/v12.0/postgresql-12.0.tar.bz2"
    FILENAME "postgresql-12.0.tar.bz2"
    SHA512 231a0b5c181c33cb01c3f39de1802319b79eceec6997935ab8605dea1f4583a52d0d16e5a70fcdeea313462f062503361d543433ee03d858ba332c72a665f696
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    PATCHES
        patches/windows/win_bison_flex.patch
        patches/windows/openssl_exe_path.patch
)
unset(buildenv_contents)
# Get paths to required programs
foreach(program_name BISON FLEX PERL)
    # Need to rename win_bison and win_flex to just bison and flex
    vcpkg_find_acquire_program(${program_name})
    get_filename_component(${program_name}_EXE_PATH ${${program_name}} DIRECTORY)
    vcpkg_add_to_path(PREPEND "${${program_name}_EXE_PATH}")
    set(buildenv_contents "${buildenv_contents}\n\$ENV{PATH}=\$ENV{PATH} . ';${${program_name}_EXE_PATH}';")
endforeach()

## Setup build types

if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE MATCHES "[Rr][Ee][Ll][Ee][Aa][Ss][Ee]")
    set(_buildtype RELEASE)
    set(_short rel)
    list(APPEND port_config_list ${_buildtype})
    set(INSTALL_PATH_SUFFIX_${_buildtype} "")
    set(BUILDPATH_${_buildtype} "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${_short}")
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
    set(PACKAGE_DIR_${_buildtype} ${CURRENT_PACKAGES_DIR}${INSTALL_PATH_SUFFIX_${_buildtype}})
    unset(_short)
    unset(_buildtype)
endif()



## Do the build
if(VCPKG_TARGET_IS_WINDOWS)
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
        )
        
        file(COPY "${CURRENT_PORT_DIR}/config.pl" DESTINATION "${BUILDPATH_${_buildtype}}/src/tools/msvc")
        set(CONFIG_FILE "${BUILDPATH_${_buildtype}}/src/tools/msvc/config.pl")
        file(READ "${CONFIG_FILE}" _contents)
        
        
        ##	ldap      => undef,    # --with-ldap
        ##	extraver  => undef,    # --with-extra-version=<string>
        ##	gss       => undef,    # --with-gssapi=<path>
        ##	icu       => undef,    # --with-icu=<path>
        ##	nls       => undef,    # --enable-nls=<path>
        ##	tap_tests => undef,    # --enable-tap-tests
        ##	tcl       => undef,    # --with-tcl=<path>
        ##	perl      => undef,    # --with-perl
        ##	python    => undef,    # --with-python=<path>
        ##	openssl   => undef,    # --with-openssl=<path>
        ##	uuid      => undef,    # --with-ossp-uuid
        ##	xml       => undef,    # --with-libxml=<path>
        ##	xslt      => undef,    # --with-libxslt=<path>
        ##	iconv     => undef,    # (not in configure, path to iconv)
        ##	zlib      => undef     # --with-zlib=<path>
        
        ## Setup external dependencies
        ##"-DFEATURES=core;openssl;zlib" "-DALL_FEATURES=openssl;zlib;readline;libedit;perl;python;tcl;nls;kerberos;systemd;ldap;bsd;pam;llvm;icu;bonjour;uuid;xml;xslt;"
        if("${FEATURES}" MATCHES "openssl")
            set(buildenv_contents "${buildenv_contents}\n\$ENV{PATH}=\$ENV{PATH} . ';${CURRENT_INSTALLED_DIR}/tools/openssl';")
            #set(_contents "${_contents}\n\$ENV{PATH}=\$ENV{PATH} . ';${CURRENT_INSTALLED_DIR}/tools/openssl';")
            string(REPLACE "openssl   => undef" "openssl   => \"${CURRENT_INSTALLED_DIR}\"" _contents "${_contents}")
        endif()

        if("${FEATURES}" MATCHES "xml")
           string(REPLACE "xml      => undef" "xml      => \"${CURRENT_INSTALLED_DIR}\"" _contents "${_contents}")
           string(REPLACE "iconv      => undef" "iconv      => \"${CURRENT_INSTALLED_DIR}\"" _contents "${_contents}")
        endif()

        if("${FEATURES}" MATCHES "xslt")
           string(REPLACE "xslt      => undef" "xslt      => \"${CURRENT_INSTALLED_DIR}\"" _contents "${_contents}")
        endif()

        if("${FEATURES}" MATCHES "nls")
           string(REPLACE "nls      => undef" "nls      => \"${CURRENT_INSTALLED_DIR}\"" _contents "${_contents}")
        endif()

        if("${FEATURES}" MATCHES "xslt")
           string(REPLACE "xslt      => undef" "xslt      => \"${CURRENT_INSTALLED_DIR}\"" _contents "${_contents}")
        endif()

        if("${FEATURES}" MATCHES "zlib")
           string(REPLACE "zlib      => undef" "zlib      => \"${CURRENT_INSTALLED_DIR}\"" _contents "${_contents}")
        endif()
        
        if("${FEATURES}" MATCHES "ldap")
            string(REPLACE "ldap      => undef" "ldap      => 1" _contents "${_contents}")
        endif()
        
        file(WRITE "${CONFIG_FILE}" "${_contents}")
        file(WRITE "${BUILDPATH_${_buildtype}}/src/tools/msvc/buildenv.pl" "${buildenv_contents}")
        vcpkg_get_windows_sdk(VCPKG_TARGET_PLATFORM_VERSION)
        set(ENV{MSBFLAGS} "/t:Rebuild
            /p:Platform=Win32
            /p:PlatformToolset=${VCPKG_PLATFORM_TOOLSET}
            /p:VCPkgLocalAppDataDisabled=true
            /p:UseIntelMKL=No
            /p:WindowsTargetPlatformVersion=${VCPKG_TARGET_PLATFORM_VERSION}
            /m
            /p:ForceImportBeforeCppTargets=${SCRIPTS}/buildsystems/msbuild/vcpkg.targets
            /p:VcpkgTriplet=${TARGET_TRIPLET}"
            )
        vcpkg_execute_required_process(
            COMMAND ${PERL} build.pl ${_buildtype}
            WORKING_DIRECTORY ${BUILDPATH_${_buildtype}}/src/tools/msvc
            LOGNAME build-${TARGET_TRIPLET}-${CMAKE_BUILD_TYPE}-${_buildtype}
        )
        vcpkg_execute_required_process(
            COMMAND ${PERL} install.pl ${CURRENT_PACKAGES_DIR}${INSTALL_PATH_SUFFIX_${_buildtype}} 
            WORKING_DIRECTORY ${BUILDPATH_${_buildtype}}/src/tools/msvc
            LOGNAME install-${TARGET_TRIPLET}-${CMAKE_BUILD_TYPE}-${_buildtype}
        )
    endforeach()
else()
    vcpkg_configure_make(
        SOURCE_PATH ${SOURCE_PATH}
        OPTIONS
            --without-readline
        OPTIONS_DEBUG
            --enable-debug
    )
    vcpkg_install_make()
endif()
vcpkg_copy_pdbs()

file(INSTALL ${SOURCE_PATH}/COPYRIGHT DESTINATION ${CURRENT_PACKAGES_DIR}/share/libpq RENAME copyright)
