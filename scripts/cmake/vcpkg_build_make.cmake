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
    
    set(MAKE )
    set(MAKE_OPTS )
    set(INSTALL_OPTS )
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
            # Set make command and install command
            set(MAKE "${BASH} make --noprofile --norc")
            set(_VCPKG_MAKE_GENERATOR install)
        else()
            find_program(MAKE make)
            # Set make command and install command
            set(MAKE make)
            set(INSTALL_OPTS install)
        endif()
        if (_VCPKG_PROJECT_SUBPATH)
            set(_VCPKG_PROJECT_SUBPATH /${_VCPKG_PROJECT_SUBPATH})
        else()
            set(_VCPKG_PROJECT_SUBPATH )
        endif()
    elseif (_VCPKG_MAKE_GENERATOR STREQUAL "nmake")
        find_program(NMAKE nmake)
        get_filename_component(NMAKE_EXE_PATH ${NMAKE} DIRECTORY)
        set(ENV{PATH} "$ENV{PATH};${NMAKE_EXE_PATH}")
        # Set make command and install command
        set(MAKE ${NMAKE} /NOLOGO /G /U)
        set(MAKE_OPTS -f makefile.vc all)
        set(INSTALL_OPTS install)
        # Add subpath to work directory
        if (_VCPKG_NMAKE_PROJECT_SUBPATH)
            set(_VCPKG_NMAKE_PROJECT_SUBPATH /${_VCPKG_NMAKE_PROJECT_SUBPATH})
        else()
            set(_VCPKG_NMAKE_PROJECT_SUBPATH )
        endif()
    else()
        message(FATAL_ERROR "${_VCPKG_MAKE_GENERATOR} not supported.")
    endif()
    
    set(ENV{INCLUDE} "${CURRENT_INSTALLED_DIR}/include;$ENV{INCLUDE}")
    
    if (NOT _VCPKG_MAKE_GENERATOR STREQUAL "nmake")
        # For make or other generator
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
                    # In NO_DEBUG mode, we only use ${TARGET_TRIPLET} directory.
                    if (_VCPKG_NO_DEBUG)
                        set(SHORT_BUILDTYPE "")
                    else()
                        set(SHORT_BUILDTYPE "-rel")
                    endif()
                    set(CONFIG "Release")
                endif()
    
                message(STATUS "Building ${TARGET_TRIPLET}${SHORT_BUILDTYPE}")
    
                
                vcpkg_execute_required_process(
                    COMMAND ${MAKE} ${MAKE_OPTS}
                    WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}${SHORT_BUILDTYPE}${_VCPKG_PROJECT_SUBPATH}
                    LOGNAME "${_bc_LOGFILE_ROOT}-${TARGET_TRIPLET}${SHORT_BUILDTYPE}"
                )
    
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
                    set(CONFIG "Debug")
                else()
                    # In NO_DEBUG mode, we only use ${TARGET_TRIPLET} directory.
                    if (_VCPKG_NO_DEBUG)
                        set(SHORT_BUILDTYPE "")
                    else()
                        set(SHORT_BUILDTYPE "-rel")
                    endif()
                    set(CONFIG "Release")
                endif()
                message(STATUS "Installing ${TARGET_TRIPLET}${SHORT_BUILDTYPE}")
                vcpkg_execute_required_process(
                    COMMAND ${MAKE} ${INSTALL_OPTS}
                    WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}${SHORT_BUILDTYPE}${_VCPKG_PROJECT_SUBPATH}
                    LOGNAME "install-${TARGET_TRIPLET}${SHORT_BUILDTYPE}"
                )
            endforeach()
        endif()
    else()
        # For nmake
        set(EXTRA_OPT OPTS=pdbs OPTS=symbols)
        foreach(BUILDTYPE "debug" "release")
            if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL BUILDTYPE)
                if(BUILDTYPE STREQUAL "debug")
                    # Skip debug generate
                    if (_VCPKG_NO_DEBUG)
                        continue()
                    endif()
                    # Generate obj dir suffix
                    set(SHORT_BUILDTYPE "-dbg")
                    set(CONFIG "Debug")
                    # Add install command and arguments
                    if (_bc_ENABLE_INSTALL)
                        set(INSTALL_OPTS ${INSTALL_OPTS} INSTALLDIR=${CURRENT_PACKAGES_DIR}/debug)
                        set(MAKE_OPTS ${MAKE_OPTS} ${INSTALL_OPTS})
                    endif()
                    set(MAKE_OPTS ${MAKE_OPTS} ${_VCPKG_NMAKE_OPTION_DEBUG} ${EXTRA_OPT})
                else()
                    # In NO_DEBUG mode, we only use ${TARGET_TRIPLET} directory.
                    if (_VCPKG_NO_DEBUG)
                        set(SHORT_BUILDTYPE "")
                    else()
                        set(SHORT_BUILDTYPE "-rel")
                    endif()
                    set(CONFIG "Release")
                    # Add install command and arguments
                    if (_bc_ENABLE_INSTALL)
                        set(INSTALL_OPTS ${INSTALL_OPTS} INSTALLDIR=${CURRENT_PACKAGES_DIR})
                        set(MAKE_OPTS ${MAKE_OPTS} ${INSTALL_OPTS})
                    endif()
                    set(MAKE_OPTS ${MAKE_OPTS} ${_VCPKG_NMAKE_OPTION_RELEASE} ${EXTRA_OPT})
                endif()

                if (NOT _bc_ENABLE_INSTALL)
                    message(STATUS "Building ${TARGET_TRIPLET}${SHORT_BUILDTYPE}")
                else()
                    message(STATUS "Building and installing ${TARGET_TRIPLET}${SHORT_BUILDTYPE}")
                endif()

                vcpkg_execute_required_process(
                    COMMAND ${MAKE} ${MAKE_OPTS}
                    WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}${SHORT_BUILDTYPE}${_VCPKG_NMAKE_PROJECT_SUBPATH}
                    LOGNAME "${_bc_LOGFILE_ROOT}-${TARGET_TRIPLET}${SHORT_BUILDTYPE}"
                )

                if(_bc_ADD_BIN_TO_PATH)
                    set(ENV{PATH} "${_BACKUP_ENV_PATH}")
                endif()
            endif()
        endforeach()
    endif()
endfunction()
