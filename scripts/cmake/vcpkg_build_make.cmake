## # vcpkg_build_make
##
## Build a linux makefile project.
##
## ## Usage:
## ```cmake
## vcpkg_build_make([TARGET <target>])
## ```
##
## ### TARGET
## The target passed to the configure/make build command (`./configure/make/make install`). If not specified, no target will
## be passed.
##
## ### ADD_BIN_TO_PATH
## Adds the appropriate Release and Debug `bin\` directories to the path during the build such that executables can run against the in-tree DLLs.
##
## ## Notes:
## This command should be preceeded by a call to [`vcpkg_configure_make()`](vcpkg_configure_make.md).
## You can use the alias [`vcpkg_install_make()`](vcpkg_configure_make.md) function if your CMake script supports the
## "install" target
##
## ## Examples
##
## * [x264](https://github.com/Microsoft/vcpkg/blob/master/ports/x264/portfile.cmake)
## * [tcl](https://github.com/Microsoft/vcpkg/blob/master/ports/tcl/portfile.cmake)
## * [freexl](https://github.com/Microsoft/vcpkg/blob/master/ports/freexl/portfile.cmake)
## * [libosip2](https://github.com/Microsoft/vcpkg/blob/master/ports/libosip2/portfile.cmake)
function(vcpkg_build_make)
    cmake_parse_arguments(_bc "ADD_BIN_TO_PATH;ENABLE_INSTALL" "LOGFILE_ROOT" "" ${ARGN})

    if(NOT _bc_LOGFILE_ROOT)
        set(_bc_LOGFILE_ROOT "build")
    endif()
    
    if (_VCPKG_PROJECT_SUBPATH)
        set(_VCPKG_PROJECT_SUBPATH /${_VCPKG_PROJECT_SUBPATH}/)
    endif()
    
    set(MAKE )
    set(MAKE_OPTS )
    set(INSTALL_OPTS )
    if (_VCPKG_MAKE_GENERATOR STREQUAL "make")
        if (CMAKE_HOST_WIN32)
            # Compiler requriements
            vcpkg_find_acquire_program(YASM)
            vcpkg_find_acquire_program(PERL)
            vcpkg_acquire_msys(MSYS_ROOT PACKAGES make)
            get_filename_component(YASM_EXE_PATH ${YASM} DIRECTORY)
            get_filename_component(PERL_EXE_PATH ${PERL} DIRECTORY)
            
            set(PATH_GLOBAL "$ENV{PATH}")
            set(ENV{PATH} "$ENV{PATH};${YASM_EXE_PATH};${MSYS_ROOT}/usr/bin;${PERL_EXE_PATH}")
            set(BASH ${MSYS_ROOT}/usr/bin/bash.exe)
            # Set make command and install command
            set(MAKE ${BASH} --noprofile --norc -c "${_VCPKG_PROJECT_SUBPATH}make")
            # Must use absolute path to call make in windows
            set(MAKE_OPTS -j ${VCPKG_CONCURRENCY})
            set(INSTALL_OPTS install -j ${VCPKG_CONCURRENCY})
        else()
            # Compiler requriements
            find_program(MAKE make REQUIRED)
            set(MAKE make;)
            # Set make command and install command
            set(MAKE_OPTS -j;${VCPKG_CONCURRENCY})
            set(INSTALL_OPTS install;-j;${VCPKG_CONCURRENCY})
        endif()
    elseif (_VCPKG_MAKE_GENERATOR STREQUAL "nmake")
        find_program(NMAKE nmake REQUIRED)
        get_filename_component(NMAKE_EXE_PATH ${NMAKE} DIRECTORY)
        set(PATH_GLOBAL "$ENV{PATH}")
        set(ENV{PATH} "$ENV{PATH};${NMAKE_EXE_PATH}")
        set(ENV{CL} "$ENV{CL} /MP")
        # Set make command and install command
        set(MAKE ${NMAKE} /NOLOGO /G /U)
        set(MAKE_OPTS -f makefile all)
        set(INSTALL_OPTS install)
    else()
        message(FATAL_ERROR "${_VCPKG_MAKE_GENERATOR} not supported.")
    endif()
    
    set(ENV{INCLUDE} "${CURRENT_INSTALLED_DIR}/include;$ENV{INCLUDE}")
    
    foreach(BUILDTYPE "debug" "release")
        if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL BUILDTYPE)
            if(BUILDTYPE STREQUAL "debug")
                # Skip debug generate
                if (_VCPKG_NO_DEBUG)
                    continue()
                endif()
                set(SHORT_BUILDTYPE "-dbg")
            else()
                # In NO_DEBUG mode, we only use ${TARGET_TRIPLET} directory.
                if (_VCPKG_NO_DEBUG)
                    set(SHORT_BUILDTYPE "")
                else()
                    set(SHORT_BUILDTYPE "-rel")
                endif()
            endif()
            
            if (CMAKE_HOST_WIN32)
                # In windows we can remotely call make
                set(WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}${SHORT_BUILDTYPE})
            else()
                set(WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}${SHORT_BUILDTYPE}${_VCPKG_PROJECT_SUBPATH})
            endif()
    
            message(STATUS "Building ${TARGET_TRIPLET}${SHORT_BUILDTYPE}")

            if(_bc_ADD_BIN_TO_PATH)
                set(_BACKUP_ENV_PATH "$ENV{PATH}")
                if(CMAKE_HOST_WIN32)
                    set(_PATHSEP ";")
                else()
                    set(_PATHSEP ":")
                endif()
                if(BUILDTYPE STREQUAL "debug")
                    set(ENV{PATH} "${CURRENT_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/debug/bin${_PATHSEP}$ENV{PATH}")
                else()
                    set(ENV{PATH} "${CURRENT_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/bin${_PATHSEP}$ENV{PATH}")
                endif()
            endif()

            if (CMAKE_HOST_WIN32)
                vcpkg_execute_build_process(
                    COMMAND "${MAKE} ${MAKE_OPTS}"
                    WORKING_DIRECTORY ${WORKING_DIRECTORY}
                    LOGNAME "${_bc_LOGFILE_ROOT}-${TARGET_TRIPLET}${SHORT_BUILDTYPE}"
                )
            else()
                vcpkg_execute_build_process(
                    COMMAND "${MAKE};${MAKE_OPTS}"
                    WORKING_DIRECTORY ${WORKING_DIRECTORY}
                    LOGNAME "${_bc_LOGFILE_ROOT}-${TARGET_TRIPLET}${SHORT_BUILDTYPE}"
                )
            endif()

            if(_bc_ADD_BIN_TO_PATH)
                set(ENV{PATH} "${_BACKUP_ENV_PATH}")
            endif()
        endif()
    endforeach()
    
    if (_bc_ENABLE_INSTALL)
        foreach(BUILDTYPE "debug" "release")
            if(BUILDTYPE STREQUAL "debug")
                # Skip debug generate
                if (_VCPKG_NO_DEBUG)
                    continue()
                endif()
                set(SHORT_BUILDTYPE "-dbg")
            else()
                # In NO_DEBUG mode, we only use ${TARGET_TRIPLET} directory.
                if (_VCPKG_NO_DEBUG)
                    set(SHORT_BUILDTYPE "")
                else()
                    set(SHORT_BUILDTYPE "-rel")
                endif()
            endif()
            
            message(STATUS "Installing ${TARGET_TRIPLET}${SHORT_BUILDTYPE}")
            if (CMAKE_HOST_WIN32)
                # In windows we can remotely call make
                set(WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}${SHORT_BUILDTYPE})
                vcpkg_execute_build_process(
                    COMMAND "${MAKE} ${INSTALL_OPTS}"
                    WORKING_DIRECTORY ${WORKING_DIRECTORY}
                    LOGNAME "install-${TARGET_TRIPLET}${SHORT_BUILDTYPE}"
                )
            else()
                set(WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}${SHORT_BUILDTYPE}${_VCPKG_PROJECT_SUBPATH})
                vcpkg_execute_build_process(
                    COMMAND "${MAKE};${INSTALL_OPTS}"
                    WORKING_DIRECTORY ${WORKING_DIRECTORY}
                    LOGNAME "install-${TARGET_TRIPLET}${SHORT_BUILDTYPE}"
                )
            endif()
        endforeach()
    endif()
    
    if (CMAKE_HOST_WIN32)
        set(ENV{PATH} "${PATH_GLOBAL}")
    endif()
endfunction()
