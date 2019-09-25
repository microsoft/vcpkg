## # vcpkg_configure_make
##
## Configure configure for Debug and Release builds of a project.
##
## ## Usage
## ```cmake
## vcpkg_configure_make(
##     SOURCE_PATH <${SOURCE_PATH}>
##     [AUTOCONFIG]
##     [GENERATOR]
##     [NO_DEBUG]
##     [PRERUN_SHELL <${SHELL_PATH}>]
##     [OPTIONS <-DUSE_THIS_IN_ALL_BUILDS=1>...]
##     [OPTIONS_RELEASE <-DOPTIMIZE=1>...]
##     [OPTIONS_DEBUG <-DDEBUGGABLE=1>...]
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
## ### AUTOCONFIG
## Need to use autoconfig to generate configure file.
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
## ## Notes
## This command supplies many common arguments to configure. To see the full list, examine the source.
function(vcpkg_configure_make)
    cmake_parse_arguments(_csc
        "AUTOCONFIG;NO_DEBUG"
        "SOURCE_PATH;PROJECT_SUBPATH;GENERATOR;PRERUN_SHELL"
        "OPTIONS;OPTIONS_DEBUG;OPTIONS_RELEASE"
        ${ARGN}
    )
    
    if(NOT VCPKG_PLATFORM_TOOLSET)
        message(FATAL_ERROR "Vcpkg has been updated with VS2017 support; "
            "however, vcpkg.exe must be rebuilt by re-running bootstrap-vcpkg.bat\n")
    endif()
    
    if (_csc_OPTIONS_DEBUG STREQUAL _csc_OPTIONS_RELEASE OR NMAKE_OPTION_RELEASE STREQUAL NMAKE_OPTION_DEBUG)
        message(FATAL_ERROR "Detected debug configuration is equal to release configuration, please use NO_DEBUG for vcpkg_configure_make")
    endif()

    if(_csc_GENERATOR MATCHES "NMake")
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
    
    if (_csc_AUTOCONFIG AND NOT CMAKE_HOST_WIN32)
        find_program(autoreconf autoreconf REQUIRED)
    endif()

    set(SKIP_CONFIGURE OFF)
    set(WIN_TARGET_ARCH )
    set(WIN_TARGET_COMPILER )
    if (GENERATOR STREQUAL "nmake")
        message(STATUS "Using generator NMAKE")
        find_program(NMAKE nmake REQUIRED)
        set(SKIP_CONFIGURE ON)
    elseif (GENERATOR STREQUAL "make")
        message(STATUS "Using generator make")
        if (CMAKE_HOST_WIN32)
            vcpkg_find_acquire_program(YASM)
            vcpkg_find_acquire_program(PERL)
            vcpkg_acquire_msys(MSYS_ROOT PACKAGES make)
            vcpkg_acquire_msys(MSYS_ROOT PACKAGES diffutils)
            vcpkg_acquire_msys(MSYS_ROOT PACKAGES make)
            get_filename_component(YASM_EXE_PATH ${YASM} DIRECTORY)
            get_filename_component(PERL_EXE_PATH ${PERL} DIRECTORY)
            

            if(VCPKG_TARGET_ARCHITECTURE STREQUAL x86)
                set(WIN_TARGET_ARCH --host=x86-pc-mingw32)
            elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL x64)
                set(WIN_TARGET_ARCH --host=x86_64-pc-mingw64)
            elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL arm)
                set(WIN_TARGET_ARCH --host=arm-pc-mingw32)
            endif()
            set(WIN_TARGET_COMPILER CC=cl)
            message(STATUS "PERL_EXE_PATH ; ${PERL_EXE_PATH}")
            set(ENV{PATH} "${YASM_EXE_PATH};${MSYS_ROOT}/usr/bin;$ENV{PATH};${PERL_EXE_PATH}")
            set(BASH ${MSYS_ROOT}/usr/bin/bash.exe)
        else()
            find_program(MAKE make REQUIRED)
        endif()
    else()
        message(FATAL_ERROR "${GENERATOR} not supported.")
    endif()
    
    if (NOT _csc_NO_DEBUG)
        file(REMOVE_RECURSE "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel" "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg")
    else()
        file(REMOVE_RECURSE "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}")
    endif()

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

    set(base_cmd )
    if(CMAKE_HOST_WIN32)
        set(base_cmd ${BASH} --noprofile --norc -c ${WIN_TARGET_COMPILER} )
        set(rel_command
            ${base_cmd} "./configure" ${WIN_TARGET_ARCH} "${_csc_OPTIONS}" "${_csc_OPTIONS_RELEASE}"
        )
        set(dbg_command
            ${base_cmd} "./configure" ${WIN_TARGET_ARCH} "${_csc_OPTIONS}" "${_csc_OPTIONS_DEBUG}"
        )
    else()
        set(base_cmd ./)
        set(rel_command
            ${base_cmd}configure "${_csc_OPTIONS}" "${_csc_OPTIONS_RELEASE}"
        )
        set(dbg_command
            ${base_cmd}configure "${_csc_OPTIONS}" "${_csc_OPTIONS_DEBUG}"
        )
    endif()
    
    # Configure debug
    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug" AND NOT _csc_NO_DEBUG)
        set(OBJ_DIR ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg)
        set(PRJ_DIR ${OBJ_DIR}/${_csc_PROJECT_SUBPATH})
        
        file(MAKE_DIRECTORY ${OBJ_DIR})
        file(GLOB SOURCE_FILES ${_csc_SOURCE_PATH}/*)
        foreach(ONE_SOUCRCE_FILE ${SOURCE_FILES})
            file(COPY ${ONE_SOUCRCE_FILE} DESTINATION ${OBJ_DIR})
        endforeach()
        
        if (NOT SKIP_CONFIGURE)
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
                vcpkg_execute_required_process(
                    COMMAND autoreconf -v --install
                    WORKING_DIRECTORY ${PRJ_DIR}
                    LOGNAME prerun-${TARGET_TRIPLET}-dbg
                )
            endif()
            
            message(STATUS "Configuring ${TARGET_TRIPLET}-dbg")
            vcpkg_execute_required_process(
                COMMAND ${dbg_command}
                WORKING_DIRECTORY ${PRJ_DIR}
                LOGNAME config-${TARGET_TRIPLET}-dbg
            )
        endif()
    endif()

    # Configure release
    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
        if (_csc_NO_DEBUG)
            set(TAR_TRIPLET_DIR ${TARGET_TRIPLET})
            set(OBJ_DIR ${CURRENT_BUILDTREES_DIR}/${TAR_TRIPLET_DIR})
        else()
            set(TAR_TRIPLET_DIR ${TARGET_TRIPLET}-rel)
            set(OBJ_DIR ${CURRENT_BUILDTREES_DIR}/${TAR_TRIPLET_DIR})
        endif()
        set(PRJ_DIR ${OBJ_DIR}/${_csc_PROJECT_SUBPATH})
        
        file(MAKE_DIRECTORY ${OBJ_DIR})
        file(GLOB SOURCE_FILES ${_csc_SOURCE_PATH}/*)
        foreach(ONE_SOUCRCE_FILE ${SOURCE_FILES})
            file(COPY ${ONE_SOUCRCE_FILE} DESTINATION ${OBJ_DIR})
        endforeach()
        
        if (NOT SKIP_CONFIGURE)
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
                vcpkg_execute_required_process(
                    COMMAND autoreconf -v --install
                    WORKING_DIRECTORY ${PRJ_DIR}
                    LOGNAME prerun-${TAR_TRIPLET_DIR}
                )
            endif()
            
            message(STATUS "Configuring ${TAR_TRIPLET_DIR}")
            vcpkg_execute_required_process(
                COMMAND ${rel_command}
                WORKING_DIRECTORY ${PRJ_DIR}
                LOGNAME config-${TAR_TRIPLET_DIR}
            )
        endif()
    endif()
    set(_VCPKG_MAKE_GENERATOR "${GENERATOR}" PARENT_SCOPE)
    set(_VCPKG_NO_DEBUG ${_csc_NO_DEBUG} PARENT_SCOPE)
    set(_VCPKG_PROJECT_SUBPATH ${_csc_PROJECT_SUBPATH} PARENT_SCOPE)
endfunction()
