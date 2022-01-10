# DEPRECATED BY ports/vcpkg-cmake/vcpkg_cmake_build
#[===[.md:
# vcpkg_build_cmake

Build a cmake project.

## Usage:
```cmake
vcpkg_build_cmake([DISABLE_PARALLEL] [TARGET <target>])
```

## Parameters:
### DISABLE_PARALLEL
The underlying buildsystem will be instructed to not parallelize

### TARGET
The target passed to the cmake build command (`cmake --build . --target <target>`). If not specified, no target will
be passed.

### ADD_BIN_TO_PATH
Adds the appropriate Release and Debug `bin` directories to the path during the build such that executables can run against the in-tree DLLs.

## Notes:
This command should be preceded by a call to [`vcpkg_configure_cmake()`](vcpkg_configure_cmake.md).
You can use the alias [`vcpkg_install_cmake()`](vcpkg_configure_cmake.md) function if your CMake script supports the
"install" target

## Examples:

* [zlib](https://github.com/Microsoft/vcpkg/blob/master/ports/zlib/portfile.cmake)
* [cpprestsdk](https://github.com/Microsoft/vcpkg/blob/master/ports/cpprestsdk/portfile.cmake)
* [poco](https://github.com/Microsoft/vcpkg/blob/master/ports/poco/portfile.cmake)
* [opencv](https://github.com/Microsoft/vcpkg/blob/master/ports/opencv/portfile.cmake)
#]===]

function(vcpkg_build_cmake)
    cmake_parse_arguments(PARSE_ARGV 0 "arg"
        "DISABLE_PARALLEL;ADD_BIN_TO_PATH"
        "TARGET;LOGFILE_ROOT"
        ""
    )

    if(Z_VCPKG_CMAKE_BUILD_GUARD)
        message(FATAL_ERROR "The ${PORT} port already depends on vcpkg-cmake; using both vcpkg-cmake and vcpkg_build_cmake in the same port is unsupported.")
    endif()

    if(NOT DEFINED arg_LOGFILE_ROOT)
        set(arg_LOGFILE_ROOT "build")
    endif()

    vcpkg_list(SET build_param)
    vcpkg_list(SET parallel_param)
    vcpkg_list(SET no_parallel_param)

    if("${Z_VCPKG_CMAKE_GENERATOR}" STREQUAL "Ninja")
        vcpkg_list(SET build_param "-v") # verbose output
        vcpkg_list(SET parallel_param "-j${VCPKG_CONCURRENCY}")
        vcpkg_list(SET no_parallel_param "-j1")
    elseif("${Z_VCPKG_CMAKE_GENERATOR}" MATCHES "^Visual Studio")
        vcpkg_list(SET build_param
            "/p:VCPkgLocalAppDataDisabled=true"
            "/p:UseIntelMKL=No"
        )
        vcpkg_list(SET parallel_param "/m")
    elseif("${Z_VCPKG_CMAKE_GENERATOR}" STREQUAL "NMake Makefiles")
        # No options are currently added for nmake builds
    else()
        message(FATAL_ERROR "Unrecognized GENERATOR setting from vcpkg_configure_cmake(). Valid generators are: Ninja, Visual Studio, and NMake Makefiles")
    endif()

    vcpkg_list(SET target_param)
    if(arg_TARGET)
        vcpkg_list(SET target_param "--target" "${arg_TARGET}")
    endif()

    foreach(build_type IN ITEMS debug release)
        if(NOT DEFINED VCPKG_BUILD_TYPE OR "${VCPKG_BUILD_TYPE}" STREQUAL "${build_type}")
            if("${build_type}" STREQUAL "debug")
                set(short_build_type "dbg")
                set(config "Debug")
            else()
                set(short_build_type "rel")
                set(config "Release")
            endif()

            message(STATUS "Building ${TARGET_TRIPLET}-${short_build_type}")

            if(arg_ADD_BIN_TO_PATH)
                vcpkg_backup_env_variables(VARS PATH)
                if("${build_type}" STREQUAL "debug")
                    vcpkg_add_to_path(PREPEND "${CURRENT_INSTALLED_DIR}/debug/bin")
                else()
                    vcpkg_add_to_path(PREPEND "${CURRENT_INSTALLED_DIR}/bin")
                endif()
            endif()

            if(arg_DISABLE_PARALLEL)
                vcpkg_execute_build_process(
                    COMMAND
                        "${CMAKE_COMMAND}" --build . --config "${config}" ${target_param}
                        -- ${build_param} ${no_parallel_param}
                    WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${short_build_type}"
                    LOGNAME "${arg_LOGFILE_ROOT}-${TARGET_TRIPLET}-${short_build_type}"
                )
            else()
                vcpkg_execute_build_process(
                    COMMAND
                        "${CMAKE_COMMAND}" --build . --config "${config}" ${target_param}
                        -- ${build_param} ${parallel_param}
                    NO_PARALLEL_COMMAND
                        "${CMAKE_COMMAND}" --build . --config "${config}" ${target_param}
                        -- ${build_param} ${no_parallel_param}
                    WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${short_build_type}"
                    LOGNAME "${arg_LOGFILE_ROOT}-${TARGET_TRIPLET}-${short_build_type}"
                )
            endif()

            if(arg_ADD_BIN_TO_PATH)
                vcpkg_restore_env_variables(VARS PATH)
            endif()
        endif()
    endforeach()
endfunction()
