## # vcpkg_build_gn
##
## Build google project.
##
## ## Usage:
## ```cmake
## vcpkg_build_gn([TARGET <target>])
## ```
##
## ### TARGET
## The target passed to the gn build command (`gn gen`). If not specified, no target will
## be passed.
##
## ### ADD_BIN_TO_PATH
## Adds the appropriate Release and Debug `bin\` directories to the path during the build such that executables can run against the in-tree DLLs.
##
## ## Notes:
## This command should be preceeded by a call to [`vcpkg_configure_gn()`](vcpkg_configure_gn.md).
## You can use the alias [`vcpkg_install_gn()`](vcpkg_configure_gn.md) function if your CMake script supports the
## "install" target
##
## ## Examples
##
function(vcpkg_build_gn)
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
    if (_VCPKG_MAKE_GENERATOR STREQUAL "ninja")
        vcpkg_find_acquire_program(NINJA)
    elseif (_VCPKG_MAKE_GENERATOR STREQUAL "msvc")
    else()
        message(FATAL_ERROR "${_VCPKG_MAKE_GENERATOR} not supported.")
    endif()
    
    set(ENV{INCLUDE} "${CURRENT_INSTALLED_DIR}/include;$ENV{INCLUDE}")
    
    foreach(BUILDTYPE "debug" "release")
        if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL BUILDTYPE)
            if(BUILDTYPE STREQUAL "debug")
                set(SHORT_BUILDTYPE "-dbg")
            else()
                set(SHORT_BUILDTYPE "-rel")
            endif()
            
            set(WORKING_DIRECTORY ${_VCPKG_PROJECT_SOURCE_PATH}/${_VCPKG_PROJECT_SUBPATH})
    
            message(STATUS "Building ${TARGET_TRIPLET}${SHORT_BUILDTYPE}")
            vcpkg_execute_required_process(
                COMMAND ${NINJA} -C ${WORKING_DIRECTORY}/out/${TARGET_TRIPLET}${SHORT_BUILDTYPE}
                WORKING_DIRECTORY ${WORKING_DIRECTORY}
                LOGNAME build-${TARGET_TRIPLET}${SHORT_BUILDTYPE}
            )
        endif()
    endforeach()
endfunction()
