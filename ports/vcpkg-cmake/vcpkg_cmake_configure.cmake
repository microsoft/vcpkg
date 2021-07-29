#[===[.md:
# vcpkg_cmake_configure

Configure a CMake buildsystem.

```cmake
vcpkg_cmake_configure(
    SOURCE_PATH <source-path>
    [LOGFILE_BASE <logname-base>]
    [DISABLE_PARALLEL_CONFIGURE]
    [NO_CHARSET_FLAG]
    [WINDOWS_USE_MSBUILD]
    [GENERATOR <generator>]
    [OPTIONS
        <configure-setting>...]
    [OPTIONS_RELEASE
        <configure-setting>...]
    [OPTIONS_DEBUG
        <configure-setting>...]
    [MAYBE_UNUSED_VARIABLES
        <variable-name>...]
)
```

`vcpkg_cmake_configure` configures a CMake build system for use with
`vcpkg_cmake_buildsystem_build` and `vcpkg_cmake_buildsystem_install`.
`source-path` is where the source is located; by convention,
this is usually `${SOURCE_PATH}`, which is set by one of the `vcpkg_from_*` functions.
This function configures the build system for both Debug and Release builds by default,
assuming that `VCPKG_BUILD_TYPE` is not set; if it is, then it will only configure for
that build type.

Use the `OPTIONS` argument to set the configure settings for both release and debug,
and use `OPTIONS_RELEASE` and `OPTIONS_DEBUG` to set the configure settings for
release only and debug only respectively.

By default, when possible, `vcpkg_cmake_configure` uses [ninja-build]
as its build system. If the `WINDOWS_USE_MSBUILD` argument is passed, then
`vcpkg_cmake_configure` will use a Visual Studio generator on Windows;
on every other platform, `vcpkg_cmake_configure` just uses Ninja.

[ninja-build]: https://ninja-build.org/

Additionally, one may pass the specific generator a port should use with `GENERATOR`.
This is useful if some project-specific buildsystem
has been wrapped in a CMake build system that doesn't perform an actual build.
If used for this purpose, it should be set to `"NMake Makefiles"`.
`vcpkg_cmake_buildsystem_build` and `install` do not support this being set to anything
except for NMake.

For libraries which cannot be configured in parallel,
pass the `DISABLE_PARALLEL_CONFIGURE` flag. This is needed, for example,
if the library's build system writes back into the source directory during configure.
This also disables the `CMAKE_DISABLE_SOURCE_CHANGES` option.

By default, this function adds flags to `CMAKE_C_FLAGS` and `CMAKE_CXX_FLAGS`
which set the default character set to utf-8 for MSVC.
If the library sets its own code page, pass the `NO_CHARSET_FLAG` option.

This function makes certain that all options passed in are used by the
underlying CMake build system. If there are options that might be unused,
perhaps on certain platforms, pass those variable names to
`MAYBE_UNUSED_VARIABLES`.

`LOGFILE_BASE` is used to set the base of the logfile names;
by default, this is `config`, and thus the logfiles end up being something like
`config-x86-windows-dbg.log`. You can set it to anything you like;
if you set it to `config-the-first`,
you'll get something like `config-the-first-x86-windows.dbg.log`.

## Notes
This command supplies many common arguments to CMake. To see the full list, examine the source.

## Examples

* [zlib](https://github.com/Microsoft/vcpkg/blob/master/ports/zlib/portfile.cmake)
* [cpprestsdk](https://github.com/Microsoft/vcpkg/blob/master/ports/cpprestsdk/portfile.cmake)
* [poco](https://github.com/Microsoft/vcpkg/blob/master/ports/poco/portfile.cmake)
* [opencv](https://github.com/Microsoft/vcpkg/blob/master/ports/opencv/portfile.cmake)
#]===]
if(Z_VCPKG_CMAKE_CONFIGURE_GUARD)
    return()
endif()
set(Z_VCPKG_CMAKE_CONFIGURE_GUARD ON CACHE INTERNAL "guard variable")

macro(z_vcpkg_cmake_configure_both_set_or_unset var1 var2)
    if(DEFINED ${var1} AND NOT DEFINED ${var2})
        message(FATAL_ERROR "If ${var1} is set, then ${var2} must be set.")
    elseif(NOT DEFINED ${var1} AND DEFINED ${var2})
        message(FATAL_ERROR "If ${var2} is set, then ${var1} must be set.")
    endif()
endmacro()

function(vcpkg_cmake_configure)
    cmake_parse_arguments(PARSE_ARGV 0 "arg"
        "PREFER_NINJA;DISABLE_PARALLEL_CONFIGURE;WINDOWS_USE_MSBUILD;NO_CHARSET_FLAG;Z_CMAKE_GET_VARS_USAGE"
        "SOURCE_PATH;GENERATOR;LOGFILE_BASE"
        "OPTIONS;OPTIONS_DEBUG;OPTIONS_RELEASE;MAYBE_UNUSED_VARIABLES"
    )

    if(NOT arg_Z_CMAKE_GET_VARS_USAGE AND DEFINED CACHE{Z_VCPKG_CMAKE_GENERATOR})
        message(WARNING "vcpkg_cmake_configure already called; this function should only be called once.")
    endif()

    if(DEFINED arg_UNPARSED_ARGUMENTS)
        message(FATAL_ERROR "vcpkg_cmake_buildsystem_build was passed extra arguments: ${arg_UNPARSED_ARGUMENTS}")
    endif()
    if(NOT DEFINED arg_SOURCE_PATH)
        message(FATAL_ERROR "SOURCE_PATH must be set")
    endif()
    if(NOT DEFINED arg_LOGFILE_BASE)
        set(arg_LOGFILE_BASE "config-${TARGET_TRIPLET}")
    endif()

    set(manually_specified_variables "")

    if(arg_Z_CMAKE_GET_VARS_USAGE)
        set(configuring_message "Getting CMake variables for ${TARGET_TRIPLET}")
    else()
        set(configuring_message "Configuring ${TARGET_TRIPLET}")

        foreach(option IN LISTS arg_OPTIONS arg_OPTIONS_RELEASE arg_OPTIONS_DEBUG)
            if(option MATCHES "^-D([^:=]*)[:=]")
                list(APPEND manually_specified_variables "${CMAKE_MATCH_1}")
            endif()
        endforeach()
        list(REMOVE_DUPLICATES manually_specified_variables)
        list(REMOVE_ITEM manually_specified_variables ${arg_MAYBE_UNUSED_VARIABLES})
        debug_message("manually specified variables: ${manually_specified_variables}")
    endif()

    if(CMAKE_HOST_WIN32)
        if(DEFINED ENV{PROCESSOR_ARCHITEW6432})
            set(host_architecture "$ENV{PROCESSOR_ARCHITEW6432}")
        else()
            set(host_architecture "$ENV{PROCESSOR_ARCHITECTURE}")
        endif()
    endif()

    set(ninja_can_be_used ON) # Ninja as generator
    set(ninja_host ON) # Ninja as parallel configurator

    if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
        set(targetting_uwp ON)
    endif()

    if(host_architecture STREQUAL "x86")
        # Prebuilt ninja binaries are only provided for x64 hosts
        set(ninja_can_be_used OFF)
        set(ninja_host OFF)
    elseif(targetting_uwp)
        # Ninja and MSBuild have many differences when targetting UWP, so use MSBuild to maximize existing compatibility
        set(ninja_can_be_used OFF)
    endif()

    set(generator)
    if(DEFINED arg_GENERATOR)
        set(generator "${arg_GENERATOR}")
    elseif(arg_WINDOWS_USE_MSBUILD OR NOT ninja_can_be_used)
        if(VCPKG_PLATFORM_TOOLSET STREQUAL "v120")
            if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
                set(generator "Visual Studio 12 2013")
            elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
                set(generator "Visual Studio 12 2013 Win64")
            elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm")
                set(generator "Visual Studio 12 2013 ARM")
            endif()
        elseif(VCPKG_PLATFORM_TOOLSET STREQUAL "v140")
            if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
                set(generator "Visual Studio 14 2015")
            elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
                set(generator "Visual Studio 14 2015 Win64")
            elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm")
                set(generator "Visual Studio 14 2015 ARM")
            endif()
        elseif(VCPKG_PLATFORM_TOOLSET STREQUAL "v141")
            if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
                set(generator "Visual Studio 15 2017")
            elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
                set(generator "Visual Studio 15 2017 Win64")
            elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm")
                set(generator "Visual Studio 15 2017 ARM")
            elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
                set(generator "Visual Studio 15 2017")
                set(arch "ARM64")
            endif()
        elseif(VCPKG_PLATFORM_TOOLSET STREQUAL "v142")
            set(generator "Visual Studio 16 2019")
            if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
                set(arch "Win32")
            elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
                set(arch "x64")
            elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm")
                set(arch "ARM")
            elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
                set(arch "ARM64")
            else()
                set(generator)
            endif()
        endif()
    else()
        set(generator "Ninja")
    endif()

    if(NOT DEFINED generator)
        if(NOT VCPKG_CMAKE_SYSTEM_NAME)
            set(VCPKG_CMAKE_SYSTEM_NAME Windows)
        endif()
        message(FATAL_ERROR "Unable to determine appropriate generator for: "
            "${VCPKG_CMAKE_SYSTEM_NAME}-${VCPKG_TARGET_ARCHITECTURE}-${VCPKG_PLATFORM_TOOLSET}")
    endif()

    # If we use Ninja, make sure it's on PATH
    if(generator STREQUAL "Ninja" AND NOT DEFINED ENV{VCPKG_FORCE_SYSTEM_BINARIES})
        vcpkg_find_acquire_program(NINJA)
        get_filename_component(ninja_path "${NINJA}" DIRECTORY)
        vcpkg_add_to_path("${ninja_path}")
        list(APPEND arg_OPTIONS "-DCMAKE_MAKE_PROGRAM=${NINJA}")
    endif()

    file(REMOVE_RECURSE
        "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel"
        "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg")

    if(DEFINED VCPKG_CMAKE_SYSTEM_NAME)
        list(APPEND arg_OPTIONS "-DCMAKE_SYSTEM_NAME=${VCPKG_CMAKE_SYSTEM_NAME}")
        if(targetting_uwp AND NOT DEFINED VCPKG_CMAKE_SYSTEM_VERSION)
            set(VCPKG_CMAKE_SYSTEM_VERSION 10.0)
        elseif(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "Android" AND NOT DEFINED VCPKG_CMAKE_SYSTEM_VERSION)
            set(VCPKG_CMAKE_SYSTEM_VERSION 21)
        endif()
    endif()

    if(DEFINED VCPKG_CMAKE_SYSTEM_VERSION)
        list(APPEND arg_OPTIONS "-DCMAKE_SYSTEM_VERSION=${VCPKG_CMAKE_SYSTEM_VERSION}")
    endif()

    if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
        list(APPEND arg_OPTIONS "-DBUILD_SHARED_LIBS=ON")
    elseif(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
        list(APPEND arg_OPTIONS "-DBUILD_SHARED_LIBS=OFF")
    else()
        message(FATAL_ERROR
            "Invalid setting for VCPKG_LIBRARY_LINKAGE: \"${VCPKG_LIBRARY_LINKAGE}\". "
            "It must be \"static\" or \"dynamic\"")
    endif()

    z_vcpkg_cmake_configure_both_set_or_unset(VCPKG_CXX_FLAGS_DEBUG VCPKG_C_FLAGS_DEBUG)
    z_vcpkg_cmake_configure_both_set_or_unset(VCPKG_CXX_FLAGS_RELEASE VCPKG_C_FLAGS_RELEASE)
    z_vcpkg_cmake_configure_both_set_or_unset(VCPKG_CXX_FLAGS VCPKG_C_FLAGS)

    set(VCPKG_SET_CHARSET_FLAG ON)
    if(arg_NO_CHARSET_FLAG)
        set(VCPKG_SET_CHARSET_FLAG OFF)
    endif()

    if(NOT DEFINED VCPKG_CHAINLOAD_TOOLCHAIN_FILE)
        if(NOT DEFINED VCPKG_CMAKE_SYSTEM_NAME OR _TARGETTING_UWP)
            set(VCPKG_CHAINLOAD_TOOLCHAIN_FILE "${SCRIPTS}/toolchains/windows.cmake")
        elseif(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "Linux")
            set(VCPKG_CHAINLOAD_TOOLCHAIN_FILE "${SCRIPTS}/toolchains/linux.cmake")
        elseif(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "Android")
            set(VCPKG_CHAINLOAD_TOOLCHAIN_FILE "${SCRIPTS}/toolchains/android.cmake")
        elseif(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "Darwin")
            set(VCPKG_CHAINLOAD_TOOLCHAIN_FILE "${SCRIPTS}/toolchains/osx.cmake")
        elseif(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "iOS")
            set(VCPKG_CHAINLOAD_TOOLCHAIN_FILE "${SCRIPTS}/toolchains/ios.cmake")
        elseif(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "FreeBSD")
            set(VCPKG_CHAINLOAD_TOOLCHAIN_FILE "${SCRIPTS}/toolchains/freebsd.cmake")
        elseif(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "OpenBSD")
            set(VCPKG_CHAINLOAD_TOOLCHAIN_FILE "${SCRIPTS}/toolchains/openbsd.cmake")
        elseif(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "MinGW")
            set(VCPKG_CHAINLOAD_TOOLCHAIN_FILE "${SCRIPTS}/toolchains/mingw.cmake")
        endif()
    endif()


    list(JOIN VCPKG_TARGET_ARCHITECTURE "\;" target_architecture_string)
    list(APPEND arg_OPTIONS
        "-DVCPKG_CHAINLOAD_TOOLCHAIN_FILE=${VCPKG_CHAINLOAD_TOOLCHAIN_FILE}"
        "-DVCPKG_TARGET_TRIPLET=${TARGET_TRIPLET}"
        "-DVCPKG_SET_CHARSET_FLAG=${VCPKG_SET_CHARSET_FLAG}"
        "-DVCPKG_PLATFORM_TOOLSET=${VCPKG_PLATFORM_TOOLSET}"
        "-DCMAKE_EXPORT_NO_PACKAGE_REGISTRY=ON"
        "-DCMAKE_FIND_PACKAGE_NO_PACKAGE_REGISTRY=ON"
        "-DCMAKE_FIND_PACKAGE_NO_SYSTEM_PACKAGE_REGISTRY=ON"
        "-DCMAKE_INSTALL_SYSTEM_RUNTIME_LIBS_SKIP=TRUE"
        "-DCMAKE_VERBOSE_MAKEFILE=ON"
        "-DVCPKG_APPLOCAL_DEPS=OFF"
        "-DCMAKE_TOOLCHAIN_FILE=${SCRIPTS}/buildsystems/vcpkg.cmake"
        "-DCMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION=ON"
        "-DVCPKG_CXX_FLAGS=${VCPKG_CXX_FLAGS}"
        "-DVCPKG_CXX_FLAGS_RELEASE=${VCPKG_CXX_FLAGS_RELEASE}"
        "-DVCPKG_CXX_FLAGS_DEBUG=${VCPKG_CXX_FLAGS_DEBUG}"
        "-DVCPKG_C_FLAGS=${VCPKG_C_FLAGS}"
        "-DVCPKG_C_FLAGS_RELEASE=${VCPKG_C_FLAGS_RELEASE}"
        "-DVCPKG_C_FLAGS_DEBUG=${VCPKG_C_FLAGS_DEBUG}"
        "-DVCPKG_CRT_LINKAGE=${VCPKG_CRT_LINKAGE}"
        "-DVCPKG_LINKER_FLAGS=${VCPKG_LINKER_FLAGS}"
        "-DVCPKG_LINKER_FLAGS_RELEASE=${VCPKG_LINKER_FLAGS_RELEASE}"
        "-DVCPKG_LINKER_FLAGS_DEBUG=${VCPKG_LINKER_FLAGS_DEBUG}"
        "-DVCPKG_TARGET_ARCHITECTURE=${target_architecture_string}"
        "-DCMAKE_INSTALL_LIBDIR:STRING=lib"
        "-DCMAKE_INSTALL_BINDIR:STRING=bin"
        "-D_VCPKG_ROOT_DIR=${VCPKG_ROOT_DIR}"
        "-D_VCPKG_INSTALLED_DIR=${_VCPKG_INSTALLED_DIR}"
        "-DVCPKG_MANIFEST_INSTALL=OFF"
    )

    if(DEFINED arch)
        list(APPEND arg_OPTIONS "-A${arch}")
    endif()

    # Sets configuration variables for macOS builds
    foreach(config_var IN ITEMS INSTALL_NAME_DIR OSX_DEPLOYMENT_TARGET OSX_SYSROOT OSX_ARCHITECTURES)
        if(DEFINED VCPKG_${config_var})
            list(JOIN VCPKG_${config_var} "\;" config_var_value)
            list(APPEND arg_OPTIONS "-DCMAKE_${config_var}=${config_var_value}")
        endif()
    endforeach()

    # Allow overrides / additional configuration variables from triplets
    if(DEFINED VCPKG_CMAKE_CONFIGURE_OPTIONS)
        list(APPEND arg_OPTIONS "${VCPKG_CMAKE_CONFIGURE_OPTIONS}")
    endif()
    if(DEFINED VCPKG_CMAKE_CONFIGURE_OPTIONS_RELEASE)
        list(APPEND arg_OPTIONS_RELEASE "${VCPKG_CMAKE_CONFIGURE_OPTIONS_RELEASE}")
    endif()
    if(DEFINED VCPKG_CMAKE_CONFIGURE_OPTIONS_DEBUG)
        list(APPEND arg_OPTIONS_DEBUG "${VCPKG_CMAKE_CONFIGURE_OPTIONS_DEBUG}")
    endif()

    if(ninja_host AND CMAKE_HOST_WIN32 AND NOT arg_DISABLE_PARALLEL_CONFIGURE)
        list(APPEND arg_OPTIONS "-DCMAKE_DISABLE_SOURCE_CHANGES=ON")

        vcpkg_find_acquire_program(NINJA)

        if(NOT DEFINED ninja_path)
            # if ninja_path was defined above, we've already done this
            get_filename_component(ninja_path "${NINJA}" DIRECTORY)
            vcpkg_add_to_path("${ninja_path}")
        endif()

        #parallelize the configure step
        set(parallel_configure_contents
            "rule CreateProcess\n  command = $process\n\n"
        )

        if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
            set(line "build ../CMakeCache.txt: CreateProcess\n  ")
            string(APPEND line "process = \"${CMAKE_COMMAND}\" -S \"${arg_SOURCE_PATH}\" -B .. ")

            if(DEFINED arg_OPTIONS AND NOT arg_OPTIONS STREQUAL "")
                list(JOIN arg_OPTIONS "\" \"" options)
                string(APPEND line "\"${options}\" ")
            endif()
            if(DEFINED arg_OPTIONS_RELEASE AND NOT arg_OPTIONS_RELEASE STREQUAL "")
                list(JOIN arg_OPTIONS_RELEASE "\" \"" options_rel)
                string(APPEND line "\"${options_rel}\" ")
            endif()
            string(APPEND line "-G \"${generator}\" ")
            string(APPEND line "\"-DCMAKE_BUILD_TYPE=Release\" ")
            string(APPEND line "\"-DCMAKE_INSTALL_PREFIX=${CURRENT_PACKAGES_DIR}\"")
            string(APPEND parallel_configure_contents "${line}\n\n")
        endif()
        if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
            set(line "build ../../${TARGET_TRIPLET}-dbg/CMakeCache.txt: CreateProcess\n  ")
            string(APPEND line "process = \"${CMAKE_COMMAND}\" -S \"${arg_SOURCE_PATH}\" -B \"../../${TARGET_TRIPLET}-dbg\" ")

            if(DEFINED arg_OPTIONS AND NOT arg_OPTIONS STREQUAL "")
                list(JOIN arg_OPTIONS "\" \"" options)
                string(APPEND line "\"${options}\" ")
            endif()
            if(DEFINED arg_OPTIONS_DEBUG AND NOT arg_OPTIONS_DEBUG STREQUAL "")
                list(JOIN arg_OPTIONS_DEBUG "\" \"" options_dbg)
                string(APPEND line "\"${options_dbg}\" ")
            endif()
            string(APPEND line "-G \"${generator}\" ")
            string(APPEND line "\"-DCMAKE_BUILD_TYPE=Debug\" ")
            string(APPEND line "\"-DCMAKE_INSTALL_PREFIX=${CURRENT_PACKAGES_DIR}/debug\"")
            string(APPEND parallel_configure_contents "${line}\n\n")
        endif()

        file(MAKE_DIRECTORY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/vcpkg-parallel-configure")
        file(WRITE "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/vcpkg-parallel-configure/build.ninja" "${parallel_configure_contents}")

        message(STATUS "${configuring_message}")
        vcpkg_execute_required_process(
            COMMAND ninja -v
            WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/vcpkg-parallel-configure"
            LOGNAME "${arg_LOGFILE_BASE}"
        )
        list(APPEND config_logs
            "${CURRENT_BUILDTREES_DIR}/${arg_LOGFILE_BASE}-out.log"
            "${CURRENT_BUILDTREES_DIR}/${arg_LOGFILE_BASE}-err.log")
    else()
        if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
            message(STATUS "${configuring_message}-dbg")
            file(MAKE_DIRECTORY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg")
            vcpkg_execute_required_process(
                COMMAND
                    "${CMAKE_COMMAND}" "${arg_SOURCE_PATH}"
                    ${arg_OPTIONS}
                    ${arg_OPTIONS_DEBUG}
                    -G "${generator}"
                    "-DCMAKE_BUILD_TYPE=Debug"
                    "-DCMAKE_INSTALL_PREFIX=${CURRENT_PACKAGES_DIR}/debug"
                WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg"
                LOGNAME "${arg_LOGFILE_BASE}-dbg"
            )
            list(APPEND config_logs
                "${CURRENT_BUILDTREES_DIR}/${arg_LOGFILE_BASE}-dbg-out.log"
                "${CURRENT_BUILDTREES_DIR}/${arg_LOGFILE_BASE}-dbg-err.log")
        endif()

        if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
            message(STATUS "${configuring_message}-rel")
            file(MAKE_DIRECTORY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel")
            vcpkg_execute_required_process(
                COMMAND
                    "${CMAKE_COMMAND}" "${arg_SOURCE_PATH}"
                    ${arg_OPTIONS}
                    ${arg_OPTIONS_RELEASE}
                    -G "${generator}"
                    "-DCMAKE_BUILD_TYPE=Release"
                    "-DCMAKE_INSTALL_PREFIX=${CURRENT_PACKAGES_DIR}"
                WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel"
                LOGNAME "${arg_LOGFILE_BASE}-rel"
            )
            list(APPEND config_logs
                "${CURRENT_BUILDTREES_DIR}/${arg_LOGFILE_BASE}-rel-out.log"
                "${CURRENT_BUILDTREES_DIR}/${arg_LOGFILE_BASE}-rel-err.log")
        endif()
    endif()
    
    set(all_unused_variables)
    foreach(config_log IN LISTS config_logs)
        if(NOT EXISTS "${config_log}")
            continue()
        endif()
        file(READ "${config_log}" log_contents)
        debug_message("Reading configure log ${config_log}...")
        if(NOT log_contents MATCHES "Manually-specified variables were not used by the project:\n\n((    [^\n]*\n)*)")
            continue()
        endif()
        string(STRIP "${CMAKE_MATCH_1}" unused_variables) # remove leading `    ` and trailing `\n`
        string(REPLACE "\n    " ";" unused_variables "${unused_variables}")
        debug_message("unused variables: ${unused_variables}")
        foreach(unused_variable IN LISTS unused_variables)
            if(unused_variable IN_LIST manually_specified_variables)
                debug_message("manually specified unused variable: ${unused_variable}")
                list(APPEND all_unused_variables "${unused_variable}")
            else()
                debug_message("unused variable (not manually specified): ${unused_variable}")
            endif()
        endforeach()
    endforeach()

    if(DEFINED all_unused_variables)
        list(REMOVE_DUPLICATES all_unused_variables)
        list(JOIN all_unused_variables "\n    " all_unused_variables)
        message(WARNING "The following variables are not used in CMakeLists.txt:
    ${all_unused_variables}
Please recheck them and remove the unnecessary options from the `vcpkg_cmake_configure` call.
If these options should still be passed for whatever reason, please use the `MAYBE_UNUSED_VARIABLES` argument.")
    endif()

    if(NOT arg_Z_CMAKE_GET_VARS_USAGE)
        set(Z_VCPKG_CMAKE_GENERATOR "${generator}" CACHE INTERNAL "The generator which was used to configure CMake.")
    endif()
endfunction()
