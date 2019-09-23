## # vcpkg_build_cmake
##
## Build a make project.
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
function(vcpkg_build_make)
    cmake_parse_arguments(_bc "ADD_BIN_TO_PATH;ENABLE_INSTALL" "LOGFILE_ROOT" "" ${ARGN})

    if(NOT _bc_LOGFILE_ROOT)
        set(_bc_LOGFILE_ROOT "build")
    endif()
    
    if (_VCPKG_MAKE_GENERATOR STREQUAL "make")
        if (CMAKE_HOST_WIN32)
            vcpkg_find_acquire_program(YASM)
            vcpkg_find_acquire_program(PERL)
            vcpkg_acquire_msys(MSYS_ROOT PACKAGES make)
            vcpkg_acquire_msys(MSYS_ROOT PACKAGES diffutils)
            get_filename_component(YASM_EXE_PATH ${YASM} DIRECTORY)
            get_filename_component(PERL_EXE_PATH ${PERL} DIRECTORY)
            set(ENV{PATH} "${YASM_EXE_PATH};${MSYS_ROOT}/usr/bin;$ENV{PATH};${PERL_EXE_PATH}")
            set(BASH ${MSYS_ROOT}/usr/bin/bash.exe)
            
            set(MAKE_CMD "${BASH} make --noprofile --norc")
            set(INSTALL_CMD "${BASH} make install --noprofile --norc")
        else()
            find_program(MAKE make)
            set(MAKE_CMD make)
            set(INSTALL_CMD make install)
        endif()
    elseif (_VCPKG_MAKE_GENERATOR STREQUAL "nmake")
        find_program(NMAKE nmake)
        set(MAKE_CMD "${NMAKE}")
        set(INSTALL_CMD "${NMAKE} install")
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
                set(CONFIG "Debug")
            else()
                if (_VCPKG_NO_DEBUG)
                    set(SHORT_BUILDTYPE "")
                else()
                    set(SHORT_BUILDTYPE "-rel")
                endif()
                set(CONFIG "Release")
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
                    set(ENV{LIB} "${CURRENT_INSTALLED_DIR}/debug/lib;$ENV{LIB}")
                    set(ENV{PATH} "${CURRENT_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/debug/bin${_PATHSEP}$ENV{PATH}")
                else()
                    set(ENV{LIB} "${CURRENT_INSTALLED_DIR}/lib;$ENV{LIB}")
                    set(ENV{PATH} "${CURRENT_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/bin${_PATHSEP}$ENV{PATH}")
                endif()
            endif()

            vcpkg_execute_build_process(
                COMMAND ${MAKE_CMD} #${CONFIG}
                WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}${SHORT_BUILDTYPE}
                LOGNAME "${_bc_LOGFILE_ROOT}-${TARGET_TRIPLET}${SHORT_BUILDTYPE}"
            )

            if(_bc_ADD_BIN_TO_PATH)
                set(ENV{PATH} "${_BACKUP_ENV_PATH}")
            endif()
        endif()
    endforeach()
    
    foreach(BUILDTYPE "debug" "release")
        if(BUILDTYPE STREQUAL "debug")
            # Skip debug generate
            if (_VCPKG_NO_DEBUG)
                continue()
            endif()
            set(SHORT_BUILDTYPE "-dbg")
            set(CONFIG "Debug")
        else()
            if (_VCPKG_NO_DEBUG)
                set(SHORT_BUILDTYPE "")
            else()
                set(SHORT_BUILDTYPE "-rel")
            endif()
            set(CONFIG "Release")
        endif()
        if (_bc_ENABLE_INSTALL)
            message(STATUS "Installing ${TARGET_TRIPLET}${SHORT_BUILDTYPE}")
            vcpkg_execute_build_process(
                COMMAND ${INSTALL_CMD} #${CONFIG}
                WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}${SHORT_BUILDTYPE}
                LOGNAME "${_bc_LOGFILE_ROOT}-${TARGET_TRIPLET}${SHORT_BUILDTYPE}"
            )
        endif()
    endforeach()
endfunction()
