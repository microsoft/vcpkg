## # vcpkg_configure_gn
##
## Configure configure for Debug and Release builds of a project.
##
## ## Usage
## ```cmake
## vcpkg_configure_gn(
##     SOURCE_PATH <${SOURCE_PATH}>
##     [GENERATOR]
##     [PROJECT_SUBPATH <${PROJ_SUBPATH}>]
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
## ### GENERATOR
## Specifies the precise generator to use.
## NINJA: ninja
## MSVC: msvc(windows) ninja(unix)
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
##
## ## Examples
##
function(vcpkg_configure_gn)
    cmake_parse_arguments(_csc
        ""
        "SOURCE_PATH;PROJECT_SUBPATH;GENERATOR"
        "OPTIONS;OPTIONS_DEBUG;OPTIONS_RELEASE"
        ${ARGN}
    )
    
    if(NOT VCPKG_PLATFORM_TOOLSET)
        message(FATAL_ERROR "Vcpkg has been updated with VS2017 support; "
            "however, vcpkg.exe must be rebuilt by re-running bootstrap-vcpkg.bat\n")
    endif()
    
    # Select compiler
    if(_csc_GENERATOR MATCHES "MSVC")
        message(FATAL_ERROR "Sorry, msvc does not supported currently.")
        if (CMAKE_HOST_WIN32)
            set(GENERATOR "msvc")
        else()
            set(GENERATOR "ninja")
        endif()
    elseif(NOT _csc_GENERATOR OR _csc_GENERATOR MATCHES "NINJA")
        if (CMAKE_HOST_WIN32)
            set(GENERATOR "ninja")
        else()
            set(GENERATOR "ninja")
        endif()
    else()
        message(FATAL_ERROR "${_csc_GENERATOR} not supported.")
    endif()

    vcpkg_find_acquire_program(GN)
    # Detect compiler
    if (GENERATOR STREQUAL "msvc")
        message(STATUS "Using generator msvc")
    elseif (GENERATOR STREQUAL "ninja")
        message(STATUS "Using generator ninja")
        vcpkg_find_acquire_program(NINJA)
        set(ENV{GYP_GENERATORS} "ninja")
    else()
        message(FATAL_ERROR "${GENERATOR} not supported.")
    endif()
    
    set(EXTRA_OPTS )
    if (TRIPLET_SYSTEM_ARCH STREQUAL arm64)
        set(EXTRA_OPTS ${EXTRA_OPTS} v8_target_cpu="arm64" use_goma=true)
    endif()
    
    # Configure debug
    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
        set(TAR_TRIPLET ${TARGET_TRIPLET}-dbg)
        set(OBJ_DIR ${_csc_SOURCE_PATH}/${_csc_PROJECT_SUBPATH}/out/${TAR_TRIPLET})
        set(_${PORT}_PROJECT_OBJPATH_DEBUG ${OBJ_DIR} PARENT_SCOPE)
        
        file(REMOVE_RECURSE ${OBJ_DIR})
        
        message(STATUS "Configuring ${TAR_TRIPLET}")
        vcpkg_execute_required_process(
            COMMAND ${GN} gen ${OBJ_DIR}
            WORKING_DIRECTORY ${_csc_SOURCE_PATH}/${_csc_PROJECT_SUBPATH}
            LOGNAME configure-${TAR_TRIPLET}
        )
    endif()

    # Configure release
    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
        set(TAR_TRIPLET ${TARGET_TRIPLET}-rel)
        set(OBJ_DIR ${_csc_SOURCE_PATH}/${_csc_PROJECT_SUBPATH}/out/${TAR_TRIPLET})
        set(_${PORT}_PROJECT_OBJPATH_RELEASE ${OBJ_DIR} PARENT_SCOPE)
        
        file(REMOVE_RECURSE ${OBJ_DIR})
        
        message(STATUS "Configuring ${TAR_TRIPLET}")
        vcpkg_execute_required_process(
            COMMAND ${GN} gen ${OBJ_DIR} --args=is_debug=false
            WORKING_DIRECTORY ${_csc_SOURCE_PATH}/${_csc_PROJECT_SUBPATH}
            LOGNAME configure-${TAR_TRIPLET}
        )
    endif()
    
    set(_VCPKG_MAKE_GENERATOR "${GENERATOR}" PARENT_SCOPE)
    SET(_VCPKG_PROJECT_SOURCE_PATH ${_csc_SOURCE_PATH} PARENT_SCOPE)
    set(_VCPKG_PROJECT_SUBPATH ${_csc_PROJECT_SUBPATH} PARENT_SCOPE)
endfunction()
