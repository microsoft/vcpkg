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

    set(build_args "")
    set(target_args "")
    set(parallel_args "")
    set(no_parallel_args "")

    if(Z_VCPKG_CMAKE_GENERATOR STREQUAL "Ninja")
        set(build_args "-v") # verbose output
        set(parallel_args "-j${VCPKG_CONCURRENCY}")
        set(no_parallel_args "-j1")
    elseif(Z_VCPKG_CMAKE_GENERATOR MATCHES "^Visual Studio")
        set(build_args
            "/p:VCPkgLocalAppDataDisabled=true"
            "/p:UseIntelMKL=No"
        )
        set(parallel_args "/m")
    elseif(Z_VCPKG_CMAKE_GENERATOR STREQUAL "NMake Makefiles")
        # No options are currently added for nmake builds
    elseif(Z_VCPKG_CMAKE_GENERATOR STREQUAL "Unix Makefiles")
        set(build_args "VERBOSE=1")
        set(parallel_args "-j${VCPKG_CONCURRENCY}")
        set(no_parallel_args "")
    elseif(Z_VCPKG_CMAKE_GENERATOR STREQUAL "Xcode")
        list(APPEND parallel_args -jobs "${VCPKG_CONCURRENCY}")
        list(APPEND no_parallel_args -jobs 1)
    else()
        message(WARNING "Unrecognized GENERATOR setting from vcpkg_cmake_configure().")
    endif()

    if(DEFINED arg_TARGET)
        set(target_args "--target" "${arg_TARGET}")
    endif()

    foreach(buildtype IN ITEMS debug release)
        if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL buildtype)
            if(buildtype STREQUAL "debug")
                set(short_buildtype "dbg")
                set(cmake_config "Debug")
            else()
                set(short_buildtype "rel")
                set(cmake_config "Release")
            endif()

            message(STATUS "Building ${TARGET_TRIPLET}-${short_buildtype}")

            if(arg_ADD_BIN_TO_PATH)
                set(env_path_backup "$ENV{PATH}")
                if(buildtype STREQUAL "debug")
                    vcpkg_add_to_path(PREPEND "${CURRENT_INSTALLED_DIR}/debug/bin")
                else()
                    vcpkg_add_to_path(PREPEND "${CURRENT_INSTALLED_DIR}/bin")
                endif()
            endif()

            if (arg_DISABLE_PARALLEL)
                vcpkg_execute_build_process(
                    COMMAND "${CMAKE_COMMAND}" --build . --config "${cmake_config}" ${target_args} -- ${build_args} ${no_parallel_args}
                    WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${short_buildtype}"
                    LOGNAME "${arg_LOGFILE_BASE}-${TARGET_TRIPLET}-${short_buildtype}"
                )
            else()
                vcpkg_execute_build_process(
                    COMMAND "${CMAKE_COMMAND}" --build . --config "${cmake_config}" ${target_args} -- ${build_args} ${parallel_args}
                    NO_PARALLEL_COMMAND "${CMAKE_COMMAND}" --build . --config "${cmake_config}" ${target_args} -- ${build_args} ${no_parallel_args}
                    WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${short_buildtype}"
                    LOGNAME "${arg_LOGFILE_BASE}-${TARGET_TRIPLET}-${short_buildtype}"
                )
            endif()

            if(arg_ADD_BIN_TO_PATH)
                set(ENV{PATH} "${env_path_backup}")
            endif()
        endif()
    endforeach()
endfunction()
