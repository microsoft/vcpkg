#[===[.md:
# vcpkg_cmake_build

Build a cmake project.

```cmake
vcpkg_cmake_build(
    [TARGET <target>]
    [LOGFILE_BASE <base>]
    [DISABLE_PARALLEL]
    [ADD_BIN_TO_PATH]
)
```

`vcpkg_cmake_build` builds an already-configured cmake project.
You can use the alias [`vcpkg_cmake_install()`] function
if your CMake build system supports the `install` TARGET,
and this is something we recommend doing whenever possible.
Otherwise, you can use `TARGET` to set the target to build.
This function defaults to not passing a target to cmake.

[`vcpkg_cmake_install()`]: vcpkg_cmake_install.md

`LOGFILE_BASE` is used to set the base of the logfile names;
by default, this is `build`, and thus the logfiles end up being something like
`build-x86-windows-dbg.log`; if you use `vcpkg_cmake_install`,
this is set to `install`, so you'll get log names like `install-x86-windows-dbg.log`.

For build systems that are buggy when run in parallel,
using `DISABLE_PARALLEL` will run the build with only one job.

Finally, `ADD_BIN_TO_PATH` adds the appropriate (either release or debug)
`bin/` directories to the path during the build,
such that executables run during the build will be able to access those DLLs.
#]===]
if(Z_VCPKG_CMAKE_BUILD_GUARD)
    return()
endif()
set(Z_VCPKG_CMAKE_BUILD_GUARD ON CACHE INTERNAL "guard variable")

function(vcpkg_cmake_build)
    cmake_parse_arguments(PARSE_ARGV 0 "arg" "DISABLE_PARALLEL;ADD_BIN_TO_PATH" "TARGET;LOGFILE_BASE" "")

    if(DEFINED arg_UNPARSED_ARGUMENTS)
        message(FATAL_ERROR "vcpkg_cmake_build was passed extra arguments: ${arg_UNPARSED_ARGUMENTS}")
    endif()
    if(NOT DEFINED arg_LOGFILE_BASE)
        set(arg_LOGFILE_BASE "build")
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
    elseif(Z_VCPKG_CMAKE_GENERATOR STREQUAL "Unix Makefiles")
        vcpkg_list(SET build_args "VERBOSE=1")
        vcpkg_list(SET parallel_args "-j${VCPKG_CONCURRENCY}")
        vcpkg_list(SET no_parallel_args "")
    elseif(Z_VCPKG_CMAKE_GENERATOR STREQUAL "Xcode")
        vcpkg_list(SET parallel_args -jobs "${VCPKG_CONCURRENCY}")
        vcpkg_list(SET no_parallel_args -jobs 1)
    else()
        message(WARNING "Unrecognized GENERATOR setting from vcpkg_cmake_configure().")
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
                    LOGNAME "${arg_LOGFILE_BASE}-${TARGET_TRIPLET}-${short_build_type}"
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
                    LOGNAME "${arg_LOGFILE_BASE}-${TARGET_TRIPLET}-${short_build_type}"
                )
            endif()

            if(arg_ADD_BIN_TO_PATH)
                vcpkg_restore_env_variables(VARS PATH)
            endif()
        endif()
    endforeach()
endfunction()
