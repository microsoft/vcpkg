## # vcpkg_configure_make
##
## Configure configure for Debug and Release builds of a project.
##
## ## Usage
## ```cmake
## vcpkg_configure_make(
##     SOURCE_PATH <${SOURCE_PATH}>
##     [AUTOCONFIG]
##     [DISABLE_AUTO_HOST]
##     [DISABLE_AUTO_DST]
##     [GENERATOR]
##     [NO_DEBUG]
##     [SKIP_CONFIGURE]
##     [PROJECT_SUBPATH <${PROJ_SUBPATH}>]
##     [PRERUN_SHELL <${SHELL_PATH}>]
##     [OPTIONS <-DUSE_THIS_IN_ALL_BUILDS=1>...]
##     [OPTIONS_RELEASE <-DOPTIMIZE=1>...]
##     [OPTIONS_DEBUG <-DDEBUGGABLE=1>...]+
##     [PKG_CONFIG_PATHS <$CONFIG_PATH>]
##     [PKG_CONFIG_PATHS_DEBUG <$CONFIG_PATH>]
##     [PKG_CONFIG_PATHS_RELEASE <$CONFIG_PATH>]
## )
## ```
##
## ## Parameters
## ### SOURCE_PATH
## Specifies the directory containing the `configure`/`configure.ac`.
## By convention, this is usually set in the portfile as the variable `SOURCE_PATH`.
##
## ### PROJECT_SUBPATH
## Specifies the directory containing the ``configure`/`configure.ac`.
## By convention, this is usually set in the portfile as the variable `SOURCE_PATH`.
## Should use `GENERATOR NMake` first.
##
## ### NO_DEBUG
## This port doesn't support debug mode.
##
## ### SKIP_CONFIGURE
## Skip configure process
##
## ### AUTOCONFIG
## Need to use autoconfig to generate configure file.
##
## ### DISABLE_AUTO_HOST
## Don't set host automatically, the default value is `i686`.
## If use this option, you will need to set host manually.
##
## ### DISABLE_AUTO_DST
## Don't set installation path automatically, the default value is `${CURRENT_PACKAGES_DIR}` and `${CURRENT_PACKAGES_DIR}/debug`
## If use this option, you will need to set dst path manually.
##
## ### GENERATOR
## Specifies the precise generator to use.
## NMake: nmake(windows) make(unix)
## MAKE: make(windows) make(unix)
##
## ### PRERUN_SHELL
## Script that needs to be called before configuration
##
## ### OPTIONS
## Additional options passed to configure during the configuration.
##
## ### OPTIONS_RELEASE
## Additional options passed to configure during the Release configuration. These are in addition to `OPTIONS`.
##
## ### OPTIONS_DEBUG
## Additional options passed to configure during the Debug configuration. These are in addition to `OPTIONS`.
##
## ### PKG_CONFIG_PATHS(_RELEASE|_DEBUG)
## Appends the listed PATHS to the enviorment variable PKG_CONFIG_PATH
##
## ## Notes
## This command supplies many common arguments to configure. To see the full list, examine the source.
##
## ## Examples
##
## * [x264](https://github.com/Microsoft/vcpkg/blob/master/ports/x264/portfile.cmake)
## * [tcl](https://github.com/Microsoft/vcpkg/blob/master/ports/tcl/portfile.cmake)
## * [freexl](https://github.com/Microsoft/vcpkg/blob/master/ports/freexl/portfile.cmake)
## * [libosip2](https://github.com/Microsoft/vcpkg/blob/master/ports/libosip2/portfile.cmake)
function(vcpkg_configure_make)
    cmake_parse_arguments(_csc
        "AUTOCONFIG;DISABLE_AUTO_HOST;DISABLE_AUTO_DST;NO_DEBUG;SKIP_CONFIGURE"
        "SOURCE_PATH;PROJECT_SUBPATH;GENERATOR;PRERUN_SHELL"
        "OPTIONS;OPTIONS_DEBUG;OPTIONS_RELEASE;PKG_CONFIG_PATHS;PKG_CONFIG_PATHS_DEBUG;PKG_CONFIG_PATHS_RELEASE"
        ${ARGN}
    )
    
    if(NOT VCPKG_PLATFORM_TOOLSET)
        message(FATAL_ERROR "Vcpkg has been updated with VS2017 support; "
            "however, vcpkg.exe must be rebuilt by re-running bootstrap-vcpkg.bat\n")
    endif()
    
    if (_csc_OPTIONS_DEBUG STREQUAL _csc_OPTIONS_RELEASE OR NMAKE_OPTION_RELEASE STREQUAL NMAKE_OPTION_DEBUG)
        message(FATAL_ERROR "Detected debug configuration is equal to release configuration, please use NO_DEBUG for vcpkg_configure_make")
    endif()
    # Select compiler
    if(_csc_GENERATOR MATCHES "NMake")
        message(FATAL_ERROR "Sorry, NMake does not supported currently.")
        if (CMAKE_HOST_WIN32)
            set(GENERATOR "nmake")
        else()
            set(GENERATOR "make")
        endif()
    elseif(NOT _csc_GENERATOR OR _csc_GENERATOR MATCHES "MAKE")
        if (CMAKE_HOST_WIN32)
            set(GENERATOR "make")
        else()
            set(GENERATOR "make")
        endif()
    else()
        message(FATAL_ERROR "${_csc_GENERATOR} not supported.")
    endif()
    if(_csc_PKG_CONFIG_PATHS)
        set(BACKUP_ENV_PKG_CONFIG_PATH $ENV{PKG_CONFIG_PATH})
        foreach(_path IN LISTS _csc_PKG_CONFIG_PATHS)
            file(TO_NATIVE_PATH "${_path}" _path)
            set(ENV{PKG_CONFIG_PATH} "$ENV{PKG_CONFIG_PATH}${VCPKG_HOST_PATH_SEPARATOR}${_path}")
        endforeach()
    endif()
    set(WIN_TARGET_ARCH )
    set(WIN_TARGET_COMPILER )
    # Detect compiler
    if (GENERATOR STREQUAL "nmake")
        message(STATUS "Using generator NMAKE")
        find_program(NMAKE nmake REQUIRED)
    elseif (GENERATOR STREQUAL "make")
        message(STATUS "Using generator make")
        find_program(MAKE make REQUIRED)
    else()
        message(FATAL_ERROR "${GENERATOR} not supported.")
    endif()
    # Pre-processing windows configure requirements
    if (CMAKE_HOST_WIN32)
        vcpkg_find_acquire_program(YASM)
        vcpkg_find_acquire_program(PERL)
        set(MSYS_REQUIRE_PACKAGES diffutils)
        if (_csc_AUTOCONFIG)
            set(MSYS_REQUIRE_PACKAGES ${MSYS_REQUIRE_PACKAGES} autoconf automake m4 libtool perl)
        endif()
        vcpkg_acquire_msys(MSYS_ROOT PACKAGES ${MSYS_REQUIRE_PACKAGES})
        get_filename_component(YASM_EXE_PATH ${YASM} DIRECTORY)
        get_filename_component(PERL_EXE_PATH ${PERL} DIRECTORY)
        
        if (NOT _csc_DISABLE_AUTO_HOST)
            if(VCPKG_TARGET_ARCHITECTURE STREQUAL x86)
                set(WIN_TARGET_ARCH --host=i686-pc-mingw32)
            elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL x64)
                set(WIN_TARGET_ARCH --host=i686-pc-mingw64)
            elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL arm)
                set(WIN_TARGET_ARCH --host=arm-pc-mingw32)
            endif()
        endif()
        set(WIN_TARGET_COMPILER CC=cl)
        set(ENV{PATH} "$ENV{PATH};${YASM_EXE_PATH};${MSYS_ROOT}/usr/bin;${PERL_EXE_PATH}")
        set(BASH ${MSYS_ROOT}/usr/bin/bash.exe)
    elseif (_csc_AUTOCONFIG)
        find_program(autoreconf autoreconf REQUIRED)
    endif()
    
    if (NOT _csc_NO_DEBUG)
        file(REMOVE_RECURSE "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel" "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg")
    else()
        file(REMOVE_RECURSE "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}")
    endif()

    if (NOT _csc_DISABLE_AUTO_DST)
        set(_csc_OPTIONS_RELEASE ${_csc_OPTIONS_RELEASE}
                                --prefix=${CURRENT_PACKAGES_DIR}
                                --bindir=${CURRENT_PACKAGES_DIR}/bin
                                --sbindir=${CURRENT_PACKAGES_DIR}/bin
                                --libdir=${CURRENT_PACKAGES_DIR}/lib
                                --includedir=${CURRENT_PACKAGES_DIR}/include)
    
        set(_csc_OPTIONS_DEBUG ${_csc_OPTIONS_DEBUG}
                            --prefix=${CURRENT_PACKAGES_DIR}/debug
                            --bindir=${CURRENT_PACKAGES_DIR}/debug/bin
                            --sbindir=${CURRENT_PACKAGES_DIR}/debug/bin
                            --libdir=${CURRENT_PACKAGES_DIR}/debug/lib
                            --includedir=${CURRENT_PACKAGES_DIR}/debug/include)
    endif()
    
    set(base_cmd )
    if(CMAKE_HOST_WIN32)
        set(base_cmd ${BASH} --noprofile --norc -c)
        
        if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
            set(_csc_OPTIONS ${_csc_OPTIONS} --enable-shared)
            if (VCPKG_TARGET_IS_UWP)
                set(_csc_OPTIONS ${_csc_OPTIONS} --extra-ldflags=-APPCONTAINER --extra-ldflags=WindowsApp.lib)
            endif()
        else()
            set(_csc_OPTIONS ${_csc_OPTIONS} --enable-static)
        endif()
        # Load toolchains
        if(NOT VCPKG_CHAINLOAD_TOOLCHAIN_FILE)
            set(VCPKG_CHAINLOAD_TOOLCHAIN_FILE "${SCRIPTS}/toolchains/windows.cmake")
        endif()
        include("${VCPKG_CHAINLOAD_TOOLCHAIN_FILE}")

        set(C_FLAGS_GLOBAL "$ENV{CFLAGS} ${VCPKG_C_FLAGS}")
        set(CXX_FLAGS_GLOBAL "$ENV{CXXFLAGS} ${VCPKG_CXX_FLAGS}")
        set(LD_FLAGS_GLOBAL "$ENV{LDFLAGS}")
        
        if(VCPKG_TARGET_IS_UWP)
            set(ENV{LIBPATH} "$ENV{LIBPATH};$ENV{_WKITS10}references\\windows.foundation.foundationcontract\\2.0.0.0\\;$ENV{_WKITS10}references\\windows.foundation.universalapicontract\\3.0.0.0\\")
            set(_csc_OPTIONS ${_csc_OPTIONS} --extra-cflags=-DWINAPI_FAMILY=WINAPI_FAMILY_APP --extra-cflags=-D_WIN32_WINNT=0x0A00)
        endif()
        
        list(JOIN _csc_OPTIONS " " _csc_OPTIONS)
        list(JOIN _csc_OPTIONS_RELEASE " " _csc_OPTIONS_RELEASE)
        list(JOIN _csc_OPTIONS_DEBUG " " _csc_OPTIONS_DEBUG)
        
        set(rel_command
            ${base_cmd} "${WIN_TARGET_COMPILER} ${_csc_SOURCE_PATH}/configure ${WIN_TARGET_ARCH} ${_csc_OPTIONS} ${_csc_OPTIONS_RELEASE}"
        )
        set(dbg_command
            ${base_cmd} "${WIN_TARGET_COMPILER} ${_csc_SOURCE_PATH}/configure ${WIN_TARGET_ARCH} ${_csc_OPTIONS} ${_csc_OPTIONS_DEBUG}"
        )
    else()
        set(base_cmd ./)
        if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
            set(_csc_OPTIONS ${_csc_OPTIONS} --enable-shared --disable-static)
        else()
            set(_csc_OPTIONS ${_csc_OPTIONS} --enable-static --disable-shared)
        endif()
        set(rel_command
            ${base_cmd}configure "${_csc_OPTIONS}" "${_csc_OPTIONS_RELEASE}"
        )
        set(dbg_command
            ${base_cmd}configure "${_csc_OPTIONS}" "${_csc_OPTIONS_DEBUG}"
        )
    endif()
    
    # Configure debug
    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug" AND NOT _csc_NO_DEBUG)
        
        if(_csc_PKG_CONFIG_PATHS_DEBUG)
            set(BACKUP_ENV_PKG_CONFIG_PATH_DEBUG $ENV{PKG_CONFIG_PATH})
            foreach(_path IN LISTS _csc_PKG_CONFIG_PATHS_DEBUG)
                file(TO_NATIVE_PATH "${_path}" _path)
                set(ENV{PKG_CONFIG_PATH} "$ENV{PKG_CONFIG_PATH}${VCPKG_HOST_PATH_SEPARATOR}${_path}")
            endforeach()
        endif()
    
        if (CMAKE_HOST_WIN32)
            unset(ENV{CFLAGS})
            unset(ENV{CXXFLAGS})
            unset(ENV{LDFLAGS})
            set(TMP_CFLAGS "${C_FLAGS_GLOBAL} ${CMAKE_C_FLAGS} ${CMAKE_C_FLAGS_DEBUG}")
            string(REPLACE "/" "-" TMP_CFLAGS "${TMP_CFLAGS}")
            set(ENV{CFLAGS} ${TMP_CFLAGS})
            set(TMP_CXXFLAGS "${CXX_FLAGS_GLOBAL} ${CMAKE_CXX_FLAGS} ${CMAKE_CXX_FLAGS_DEBUG}")
            string(REPLACE "/" "-" TMP_CXXFLAGS "${TMP_CXXFLAGS}")
            set(ENV{CXXFLAGS} ${TMP_CXXFLAGS})
            set(TMP_LDFLAGS "${LD_FLAGS_GLOBAL}")
            string(REPLACE "/" "-" TMP_LDFLAGS "${TMP_LDFLAGS}")
            set(ENV{LDFLAGS} ${TMP_LDFLAGS})
        endif()
        
        set(OBJ_DIR ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg)
        set(PRJ_DIR ${OBJ_DIR}/${_csc_PROJECT_SUBPATH})
        
        file(MAKE_DIRECTORY ${OBJ_DIR})
        
        if (NOT CMAKE_HOST_WIN32)
            file(GLOB_RECURSE SOURCE_FILES ${_csc_SOURCE_PATH}/*)
            foreach(ONE_SOUCRCE_FILE ${SOURCE_FILES})
                get_filename_component(DST_DIR ${ONE_SOUCRCE_FILE} PATH)
                string(REPLACE "${_csc_SOURCE_PATH}" "${OBJ_DIR}" DST_DIR "${DST_DIR}")
                file(COPY ${ONE_SOUCRCE_FILE} DESTINATION ${DST_DIR})
            endforeach()
        endif()

        if (_csc_PRERUN_SHELL)
            message(STATUS "Prerun shell with ${TARGET_TRIPLET}-dbg")
            vcpkg_execute_required_process(
                COMMAND ${base_cmd}${_csc_PRERUN_SHELL}
                WORKING_DIRECTORY ${PRJ_DIR}
                LOGNAME prerun-${TARGET_TRIPLET}-dbg
            )
        endif()
        
        if (_csc_AUTOCONFIG)
            message(STATUS "Generating configure with ${TARGET_TRIPLET}-dbg")
            if (CMAKE_HOST_WIN32)
                vcpkg_execute_required_process(
                    COMMAND ${base_cmd} autoreconf -vfi
                    WORKING_DIRECTORY ${_csc_SOURCE_PATH}/${_csc_PROJECT_SUBPATH}
                    LOGNAME prerun-2-${TARGET_TRIPLET}-dbg
                )
            else()
                vcpkg_execute_required_process(
                    COMMAND autoreconf -vfi
                    WORKING_DIRECTORY ${PRJ_DIR}
                    LOGNAME prerun-2-${TARGET_TRIPLET}-dbg
                )
            endif()
        endif()
        
        if (NOT _csc_SKIP_CONFIGURE)
            message(STATUS "Configuring ${TARGET_TRIPLET}-dbg")
            vcpkg_execute_required_process(
                COMMAND ${dbg_command}
                WORKING_DIRECTORY ${PRJ_DIR}
                LOGNAME config-${TARGET_TRIPLET}-dbg
            )
        endif()
        set(ENV{PKG_CONFIG_PATH} "${BACKUP_ENV_PKG_CONFIG_PATH_DEBUG}")
    endif()

    # Configure release
    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
        if(_csc_PKG_CONFIG_PATHS_RELEASE)
            set(BACKUP_ENV_PKG_CONFIG_PATH_RELEASE $ENV{PKG_CONFIG_PATH})
            foreach(_path IN LISTS _csc_PKG_CONFIG_PATHS_RELEASE)
                file(TO_NATIVE_PATH "${_path}" _path)
                set(ENV{PKG_CONFIG_PATH} "$ENV{PKG_CONFIG_PATH}${VCPKG_HOST_PATH_SEPARATOR}${_path}")
            endforeach()
        endif()
    
        if (CMAKE_HOST_WIN32)
            unset(ENV{CFLAGS})
            unset(ENV{CXXFLAGS})
            unset(ENV{LDFLAGS})
            set(TMP_CFLAGS "${C_FLAGS_GLOBAL} ${CMAKE_C_FLAGS} ${CMAKE_C_FLAGS_RELEASE}")
            string(REPLACE "/" "-" TMP_CFLAGS "${TMP_CFLAGS}")
            set(ENV{CFLAGS} ${TMP_CFLAGS})
            
            set(TMP_CXXFLAGS "${CXX_FLAGS_GLOBAL} ${CMAKE_CXX_FLAGS} ${CMAKE_CXX_FLAGS_RELEASE}")
            string(REPLACE "/" "-" TMP_CXXFLAGS "${TMP_CXXFLAGS}")
            set(ENV{CXXFLAGS} ${TMP_CXXFLAGS})
            
            set(TMP_LDFLAGS "${LD_FLAGS_GLOBAL} ${CMAKE_SHARED_LINKER_FLAGS_RELEASE}")
            string(REPLACE "/" "-" TMP_LDFLAGS "${TMP_LDFLAGS}")
            set(ENV{LDFLAGS} ${TMP_LDFLAGS})
        endif()
        
        if (_csc_NO_DEBUG)
            set(TAR_TRIPLET_DIR ${TARGET_TRIPLET})
            set(OBJ_DIR ${CURRENT_BUILDTREES_DIR}/${TAR_TRIPLET_DIR})
        else()
            set(TAR_TRIPLET_DIR ${TARGET_TRIPLET}-rel)
            set(OBJ_DIR ${CURRENT_BUILDTREES_DIR}/${TAR_TRIPLET_DIR})
        endif()
        set(PRJ_DIR ${OBJ_DIR}/${_csc_PROJECT_SUBPATH})
        
        file(MAKE_DIRECTORY ${OBJ_DIR})
        
        if (NOT CMAKE_HOST_WIN32)
            file(GLOB_RECURSE SOURCE_FILES ${_csc_SOURCE_PATH}/*)
            foreach(ONE_SOUCRCE_FILE ${SOURCE_FILES})
                get_filename_component(DST_DIR ${ONE_SOUCRCE_FILE} PATH)
                string(REPLACE "${_csc_SOURCE_PATH}" "${OBJ_DIR}" DST_DIR "${DST_DIR}")
                file(COPY ${ONE_SOUCRCE_FILE} DESTINATION ${DST_DIR})
            endforeach()
        endif()
        
        if (_csc_PRERUN_SHELL)
            message(STATUS "Prerun shell with ${TAR_TRIPLET_DIR}")
            vcpkg_execute_required_process(
                COMMAND ${base_cmd}${_csc_PRERUN_SHELL}
                WORKING_DIRECTORY ${PRJ_DIR}
                LOGNAME prerun-${TAR_TRIPLET_DIR}
            )
        endif()
        
        if (_csc_AUTOCONFIG)
            message(STATUS "Generating configure with ${TAR_TRIPLET_DIR}")
            if (CMAKE_HOST_WIN32)
                vcpkg_execute_required_process(
                    COMMAND ${base_cmd} autoreconf -vfi
                    WORKING_DIRECTORY ${_csc_SOURCE_PATH}/${_csc_PROJECT_SUBPATH}
                    LOGNAME prerun-${TAR_TRIPLET_DIR}
                )
            else()
                vcpkg_execute_required_process(
                    COMMAND autoreconf -vfi
                    WORKING_DIRECTORY ${PRJ_DIR}
                    LOGNAME prerun-${TAR_TRIPLET_DIR}
                )
            endif()
        endif()
        
        if (NOT _csc_SKIP_CONFIGURE)
            message(STATUS "Configuring ${TAR_TRIPLET_DIR}")
            vcpkg_execute_required_process(
                COMMAND ${rel_command}
                WORKING_DIRECTORY ${PRJ_DIR}
                LOGNAME config-${TAR_TRIPLET_DIR}
            )
        endif()
        
        set(ENV{PKG_CONFIG_PATH} "${BACKUP_ENV_PKG_CONFIG_PATH_RELEASE}")
    endif()
    
    # Restore envs
    if (CMAKE_HOST_WIN32)
        set(ENV{CFLAGS} "${C_FLAGS_GLOBAL}")
        set(ENV{CXXFLAGS} "${CXX_FLAGS_GLOBAL}")
        set(ENV{LDFLAGS} "${LD_FLAGS_GLOBAL}")
    endif()
    set(ENV{PKG_CONFIG_PATH} "${BACKUP_ENV_PKG_CONFIG_PATH}")
    
    
    set(_VCPKG_MAKE_GENERATOR "${GENERATOR}" PARENT_SCOPE)
    set(_VCPKG_NO_DEBUG ${_csc_NO_DEBUG} PARENT_SCOPE)
    SET(_VCPKG_PROJECT_SOURCE_PATH ${_csc_SOURCE_PATH} PARENT_SCOPE)
    set(_VCPKG_PROJECT_SUBPATH ${_csc_PROJECT_SUBPATH} PARENT_SCOPE)
endfunction()
