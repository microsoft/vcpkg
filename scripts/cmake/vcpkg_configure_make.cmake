## # vcpkg_configure_cmake
##
## Configure configure for Debug and Release builds of a project.
##
## ## Usage
## ```cmake
## vcpkg_configure_make(
##     SOURCE_PATH <${SOURCE_PATH}>
##     [AUTOCONFIG]
##     [GENERATOR]
##     [PRERUN_SHELL <${SHELL_PATH}>]
##     [OPTIONS <-DUSE_THIS_IN_ALL_BUILDS=1>...]
##     [OPTIONS_RELEASE <-DOPTIMIZE=1>...]
##     [OPTIONS_DEBUG <-DDEBUGGABLE=1>...]
## )
## ```
##
## ## Parameters
## ### SOURCE_PATH
## Specifies the directory containing the `CMakeLists.txt`.
## By convention, this is usually set in the portfile as the variable `SOURCE_PATH`.
##
## ### AUTOCONFIG
## Need to use autoconfig to generate configure.
##
## ### GENERATOR
## Specifies the precise generator to use.
##
## This is useful if some project-specific buildsystem has been wrapped in a cmake script that won't perform an actual build.
## If used for this purpose, it should be set to "NMake Makefiles".
##
## ### PRERUN_SHELL
## Script that needs to be called before configuration
##
## ### OPTIONS
## Additional options passed to CMake during the configuration.
##
## ### OPTIONS_RELEASE
## Additional options passed to CMake during the Release configuration. These are in addition to `OPTIONS`.
##
## ### OPTIONS_DEBUG
## Additional options passed to CMake during the Debug configuration. These are in addition to `OPTIONS`.
##
## ## Notes
## This command supplies many common arguments to CMake. To see the full list, examine the source.
function(vcpkg_configure_make)
    cmake_parse_arguments(_csc
        "AUTOCONFIG"
        "SOURCE_PATH;GENERATOR;PRERUN_SHELL"
        "OPTIONS;OPTIONS_DEBUG;OPTIONS_RELEASE"
        ${ARGN}
    )

    if(NOT VCPKG_PLATFORM_TOOLSET)
        message(FATAL_ERROR "Vcpkg has been updated with VS2017 support; "
            "however, vcpkg.exe must be rebuilt by re-running bootstrap-vcpkg.bat\n")
    endif()

    if(CMAKE_HOST_WIN32)
        set(_PATHSEP ";")
        if(DEFINED ENV{PROCESSOR_ARCHITEW6432})
            set(_csc_HOST_ARCHITECTURE $ENV{PROCESSOR_ARCHITEW6432})
        else()
            set(_csc_HOST_ARCHITECTURE $ENV{PROCESSOR_ARCHITECTURE})
        endif()
    else()
        set(_PATHSEP ":")
    endif()

    if(_csc_GENERATOR STREQUAL NMAKE)
        if (CMAKE_HOST_WIN32)
            set(GENERATOR "nmake")
        else()
            set(GENERATOR "make")
        endif()
    elseif(_csc_GENERATOR STREQUAL MAKE OR NOT _csc_GENERATOR)
        if (CMAKE_HOST_WIN32)
            set(GENERATOR "make")
        else()
            set(GENERATOR "make")
        endif()
    else()
        message(FATAL_ERROR "${_csc_GENERATOR} not supported.")
    endif()
    
    if (_csc_AUTOCONFIG AND NOT CMAKE_HOST_WIN32)
        find_program(autoreconf autoreconf)
        if (NOT autoreconf)
            message(FATAL_ERROR "autoreconf must be installed. Install them with \"apt-get dh-autoreconf\".")
        endif()
    endif()

    # If we use Ninja, make sure it's on PATH
    if (GENERATOR STREQUAL "nmake")
        find_program(NMAKE nmake)
        if (NOT NMAKE_FOUND)
            message(FATAL_ERROR "nmake not found.")
        endif()
    elseif (GENERATOR STREQUAL "make")
        if (CMAKE_HOST_WIN32)
            vcpkg_find_acquire_program(YASM)
            vcpkg_find_acquire_program(PERL)
            vcpkg_acquire_msys(MSYS_ROOT PACKAGES make)
            vcpkg_acquire_msys(MSYS_ROOT PACKAGES diffutils)
            get_filename_component(YASM_EXE_PATH ${YASM} DIRECTORY)
            get_filename_component(PERL_EXE_PATH ${PERL} DIRECTORY)
            
            message(STATUS "PERL_EXE_PATH ; ${PERL_EXE_PATH}")
            set(ENV{PATH} "${YASM_EXE_PATH};${MSYS_ROOT}/usr/bin;$ENV{PATH};${PERL_EXE_PATH}")
            set(BASH ${MSYS_ROOT}/usr/bin/bash.exe)
        else()
            find_program(MAKE make)
            if (NOT MAKE)
                message(FATAL_ERROR "MAKE not found.")
            endif()
        endif()
    else()
        message(FATAL_ERROR "${GENERATOR} not supported.")
    endif()

    file(REMOVE_RECURSE ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg)

    set(base_cmd )
    if(CMAKE_HOST_WIN32)
        set(base_cmd ${BASH} --noprofile --norc )
        set(rel_command
            ${base_cmd} "configure" "${_csc_OPTIONS}" "${_csc_OPTIONS_RELEASE}"
        )
        set(dbg_command
            ${base_cmd} "configure" "${_csc_OPTIONS}" "${_csc_OPTIONS_DEBUG}"
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
    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
        set(OBJ_DIR ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg)
        file(MAKE_DIRECTORY ${OBJ_DIR})
        file(GLOB SOURCE_FILES ${_csc_SOURCE_PATH}/*)
        foreach(ONE_SOUCRCE_FILE ${SOURCE_FILES})
            file(COPY ${ONE_SOUCRCE_FILE} DESTINATION ${OBJ_DIR})
        endforeach()
        if (_csc_PRERUN_SHELL)
            message(STATUS "Prerun shell with ${TARGET_TRIPLET}-dbg")
            vcpkg_execute_required_process(
                COMMAND ${base_cmd}${_csc_PRERUN_SHELL}
                WORKING_DIRECTORY ${OBJ_DIR}
                LOGNAME prerun-${TARGET_TRIPLET}-dbg
            )
        endif()
        
        if (_csc_AUTOCONFIG)
            message(STATUS "Generating configure with ${TARGET_TRIPLET}-dbg")
            vcpkg_execute_required_process(
                COMMAND autoreconf -v --install
                WORKING_DIRECTORY ${OBJ_DIR}
                LOGNAME prerun-${TARGET_TRIPLET}-dbg
            )
        endif()
        
        message(STATUS "Configuring ${TARGET_TRIPLET}-dbg")
        vcpkg_execute_required_process(
            COMMAND ${dbg_command}
            WORKING_DIRECTORY ${OBJ_DIR}
            LOGNAME config-${TARGET_TRIPLET}-dbg
        )
    endif()

    # Configure release
    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
        set(OBJ_DIR ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel)
        file(MAKE_DIRECTORY ${OBJ_DIR})
        file(GLOB SOURCE_FILES ${_csc_SOURCE_PATH}/*)
        foreach(ONE_SOUCRCE_FILE ${SOURCE_FILES})
            file(COPY ${ONE_SOUCRCE_FILE} DESTINATION ${OBJ_DIR})
        endforeach()
        if (_csc_PRERUN_SHELL)
            message(STATUS "Prerun shell with ${TARGET_TRIPLET}-rel")
            vcpkg_execute_required_process(
                COMMAND ${base_cmd}${_csc_PRERUN_SHELL}
                WORKING_DIRECTORY ${OBJ_DIR}
                LOGNAME prerun-${TARGET_TRIPLET}_rel
            )
        endif()
        
        if (_csc_AUTOCONFIG)
            message(STATUS "Generating configure with ${TARGET_TRIPLET}-rel")
            vcpkg_execute_required_process(
                COMMAND autoreconf -v --install
                WORKING_DIRECTORY ${OBJ_DIR}
                LOGNAME prerun-${TARGET_TRIPLET}-dbg
            )
        endif()
        
        message(STATUS "Configuring ${TARGET_TRIPLET}-rel")
        vcpkg_execute_required_process(
            COMMAND ${rel_command}
            WORKING_DIRECTORY ${OBJ_DIR}
            LOGNAME config-${TARGET_TRIPLET}-rel
        )
    endif()
    
    set(_VCPKG_MAKE_GENERATOR "${GENERATOR}" PARENT_SCOPE)
endfunction()
