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
## ### ADD_BIN_TO_PATH
## Adds the appropriate Release and Debug `bin\` directories to the path during the build such that executables can run against the in-tree DLLs.
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
    cmake_parse_arguments(_bc "DISABLE_PARALLEL;ADD_BIN_TO_PATH" "TARGET;LOGFILE_ROOT" "" ${ARGN})

    if(NOT _bc_LOGFILE_ROOT)
        set(_bc_LOGFILE_ROOT "build")
    endif()

    set(PARALLEL_ARG)
    set(NO_PARALLEL_ARG)

    if(_VCPKG_CMAKE_GENERATOR MATCHES "Ninja")
        set(BUILD_ARGS "-v") # verbose output
        set(NO_PARALLEL_ARG "-j1")
    elseif(_VCPKG_CMAKE_GENERATOR MATCHES "Visual Studio")
        set(BUILD_ARGS
            "/p:VCPkgLocalAppDataDisabled=true"
            "/p:UseIntelMKL=No"
            "/p:PlatformToolset=${VCPKG_PLATFORM_TOOLSET}"
        )
        set(PARALLEL_ARG "/m")
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

    foreach(BUILDTYPE "debug" "release")
        if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL BUILDTYPE)
            if(BUILDTYPE STREQUAL "debug")
                set(SHORT_BUILDTYPE "dbg")
                set(CONFIG "Debug")
            else()
                set(SHORT_BUILDTYPE "rel")
                set(CONFIG "Release")
            endif()

            message(STATUS "Building ${TARGET_TRIPLET}-${SHORT_BUILDTYPE}")

            if(_bc_ADD_BIN_TO_PATH)
                set(_BACKUP_ENV_PATH "$ENV{PATH}")
                if(BUILDTYPE STREQUAL "debug")
                    vcpkg_add_to_path(PREPEND "${CURRENT_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/debug/bin")
                else()
                    vcpkg_add_to_path(PREPEND "${CURRENT_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/bin")
                endif()
            endif()

            if (_bc_DISABLE_PARALLEL)
                vcpkg_execute_build_process(
                    COMMAND ${CMAKE_COMMAND} --build . --config ${CONFIG} ${TARGET_PARAM} -- ${BUILD_ARGS} ${NO_PARALLEL_ARG}
                    WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${SHORT_BUILDTYPE}
                    LOGNAME "${_bc_LOGFILE_ROOT}-${TARGET_TRIPLET}-${SHORT_BUILDTYPE}"
                )
            else()
                vcpkg_execute_build_process(
                    COMMAND ${CMAKE_COMMAND} --build . --config ${CONFIG} ${TARGET_PARAM} -- ${BUILD_ARGS} ${PARALLEL_ARG}
                    NO_PARALLEL_COMMAND ${CMAKE_COMMAND} --build . --config ${CONFIG} ${TARGET_PARAM} -- ${BUILD_ARGS} ${NO_PARALLEL_ARG}
                    WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${SHORT_BUILDTYPE}
                    LOGNAME "${_bc_LOGFILE_ROOT}-${TARGET_TRIPLET}-${SHORT_BUILDTYPE}"
                )
            endif()

            if(_bc_ADD_BIN_TO_PATH)
                set(ENV{PATH} "${_BACKUP_ENV_PATH}")
            endif()
        endif()
    endforeach()
endfunction()
