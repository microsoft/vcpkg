## # vcpkg_build_cmake
##
## Build a cmake project.
##
## ## Usage:
## ```cmake
## vcpkg_build_cmake([DISABLE_PARALLEL] [TARGET <target>])
## ```
##
## ## Parameters:
## ### DISABLE_PARALLEL
## The underlying buildsystem will be instructed to not parallelize
##
## ### TARGET
## The target passed to the cmake build command (`cmake --build . --target <target>`). If not specified, no target will
## be passed.
##
## ## Notes:
## This command should be preceeded by a call to [`vcpkg_configure_cmake()`](vcpkg_configure_cmake.md).
## You can use the alias [`vcpkg_install_cmake()`](vcpkg_configure_cmake.md) function if your CMake script supports the
## "install" target
##
## ## Examples:
##
## * [zlib](https://github.com/Microsoft/vcpkg/blob/master/ports/zlib/portfile.cmake)
## * [cpprestsdk](https://github.com/Microsoft/vcpkg/blob/master/ports/cpprestsdk/portfile.cmake)
## * [poco](https://github.com/Microsoft/vcpkg/blob/master/ports/poco/portfile.cmake)
## * [opencv](https://github.com/Microsoft/vcpkg/blob/master/ports/opencv/portfile.cmake)
function(vcpkg_build_cmake)
    cmake_parse_arguments(_bc "DISABLE_PARALLEL" "TARGET;LOGFILE_ROOT" "" ${ARGN})

    if(NOT _bc_LOGFILE_ROOT)
        set(_bc_LOGFILE_ROOT "build")
    endif()

    if(_VCPKG_CMAKE_GENERATOR MATCHES "Ninja")
        set(BUILD_ARGS "-v") # verbose output
        if (_bc_DISABLE_PARALLEL)
            list(APPEND BUILD_ARGS "-j1")
        endif()
    elseif(_VCPKG_CMAKE_GENERATOR MATCHES "Visual Studio")
        set(BUILD_ARGS
            "/p:VCPkgLocalAppDataDisabled=true"
            "/p:UseIntelMKL=No"
        )
        if (NOT _bc_DISABLE_PARALLEL)
            list(APPEND BUILD_ARGS "/m")
        endif()
    elseif(_VCPKG_CMAKE_GENERATOR MATCHES "NMake")
        # No options are currently added for nmake builds
    else()
        message(FATAL_ERROR "Unrecognized GENERATOR setting from vcpkg_configure_cmake(). Valid generators are: Ninja, Visual Studio, and NMake Makefiles")
    endif()

    if(_bc_TARGET)
        set(TARGET_PARAM "--target" ${_bc_TARGET})
    else()
        set(TARGET_PARAM)
    endif()

    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
        message(STATUS "Build ${TARGET_TRIPLET}-rel")
        vcpkg_execute_required_process(
            COMMAND ${CMAKE_COMMAND} --build . --config Release ${TARGET_PARAM} -- ${BUILD_ARGS}
            WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel
            LOGNAME ${_bc_LOGFILE_ROOT}-${TARGET_TRIPLET}-rel
        )
        message(STATUS "Build ${TARGET_TRIPLET}-rel done")
    endif()

    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
        message(STATUS "Build ${TARGET_TRIPLET}-dbg")
        vcpkg_execute_required_process(
            COMMAND ${CMAKE_COMMAND} --build . --config Debug ${TARGET_PARAM} -- ${BUILD_ARGS}
            WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg
            LOGNAME ${_bc_LOGFILE_ROOT}-${TARGET_TRIPLET}-dbg
        )
        message(STATUS "Build ${TARGET_TRIPLET}-dbg done")
    endif()
endfunction()
