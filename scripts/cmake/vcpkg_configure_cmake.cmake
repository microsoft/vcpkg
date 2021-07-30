# DEPRECATED BY ports/vcpkg-cmake/vcpkg_cmake_configure
#[===[.md:
# vcpkg_configure_cmake

Configure CMake for Debug and Release builds of a project.

## Usage
```cmake
vcpkg_configure_cmake(
    SOURCE_PATH <${SOURCE_PATH}>
    [PREFER_NINJA]
    [DISABLE_PARALLEL_CONFIGURE]
    [NO_CHARSET_FLAG]
    [GENERATOR <"NMake Makefiles">]
    [OPTIONS <-DUSE_THIS_IN_ALL_BUILDS=1>...]
    [OPTIONS_RELEASE <-DOPTIMIZE=1>...]
    [OPTIONS_DEBUG <-DDEBUGGABLE=1>...]
    [MAYBE_UNUSED_VARIABLES <option-name>...]
)
```

## Parameters
### SOURCE_PATH
Specifies the directory containing the `CMakeLists.txt`.
By convention, this is usually set in the portfile as the variable `SOURCE_PATH`.

### PREFER_NINJA
Indicates that, when available, Vcpkg should use Ninja to perform the build.
This should be specified unless the port is known to not work under Ninja.

### DISABLE_PARALLEL_CONFIGURE
Disables running the CMake configure step in parallel.
This is needed for libraries which write back into their source directory during configure.

This also disables CMAKE_DISABLE_SOURCE_CHANGES.

### NO_CHARSET_FLAG
Disables passing `utf-8` as the default character set to `CMAKE_C_FLAGS` and `CMAKE_CXX_FLAGS`.

This is needed for libraries that set their own source code's character set.

### GENERATOR
Specifies the precise generator to use.

This is useful if some project-specific buildsystem has been wrapped in a cmake script that won't perform an actual build.
If used for this purpose, it should be set to `"NMake Makefiles"`.

### OPTIONS
Additional options passed to CMake during the configuration.

### OPTIONS_RELEASE
Additional options passed to CMake during the Release configuration. These are in addition to `OPTIONS`.

### OPTIONS_DEBUG
Additional options passed to CMake during the Debug configuration. These are in addition to `OPTIONS`.

### MAYBE_UNUSED_VARIABLES
Any CMake variables which are explicitly passed in, but which may not be used on all platforms.

### LOGNAME
Name of the log to write the output of the configure call to.

## Notes
This command supplies many common arguments to CMake. To see the full list, examine the source.

## Examples

* [zlib](https://github.com/Microsoft/vcpkg/blob/master/ports/zlib/portfile.cmake)
* [cpprestsdk](https://github.com/Microsoft/vcpkg/blob/master/ports/cpprestsdk/portfile.cmake)
* [poco](https://github.com/Microsoft/vcpkg/blob/master/ports/poco/portfile.cmake)
* [opencv](https://github.com/Microsoft/vcpkg/blob/master/ports/opencv/portfile.cmake)
#]===]

function(vcpkg_configure_cmake)
    cmake_parse_arguments(PARSE_ARGV 0 arg
        "PREFER_NINJA;DISABLE_PARALLEL_CONFIGURE;NO_CHARSET_FLAG;Z_GET_CMAKE_VARS_USAGE"
        "SOURCE_PATH;GENERATOR;LOGNAME"
        "OPTIONS;OPTIONS_DEBUG;OPTIONS_RELEASE;MAYBE_UNUSED_VARIABLES"
    )

    if(NOT arg_Z_GET_CMAKE_VARS_USAGE AND Z_VCPKG_CMAKE_CONFIGURE_GUARD)
        message(FATAL_ERROR "The ${PORT} port already depends on vcpkg-cmake; using both vcpkg-cmake and vcpkg_configure_cmake in the same port is unsupported.")
    endif()

    if(NOT VCPKG_PLATFORM_TOOLSET)
        message(FATAL_ERROR "Vcpkg has been updated with VS2017 support; "
            "however, vcpkg.exe must be rebuilt by re-running bootstrap-vcpkg.bat\n")
    endif()

    if(NOT arg_LOGNAME)
        set(arg_LOGNAME config-${TARGET_TRIPLET})
    endif()

    set(manually_specified_variables "")

    if(arg_Z_GET_CMAKE_VARS_USAGE)
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
            set(arg_HOST_ARCHITECTURE $ENV{PROCESSOR_ARCHITEW6432})
        else()
            set(arg_HOST_ARCHITECTURE $ENV{PROCESSOR_ARCHITECTURE})
        endif()
    endif()

    set(NINJA_CAN_BE_USED ON) # Ninja as generator
    set(NINJA_HOST ON) # Ninja as parallel configurator

    if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
        set(_TARGETTING_UWP 1)
    endif()

    if(arg_HOST_ARCHITECTURE STREQUAL "x86")
        # Prebuilt ninja binaries are only provided for x64 hosts
        set(NINJA_CAN_BE_USED OFF)
        set(NINJA_HOST OFF)
    elseif(_TARGETTING_UWP)
        # Ninja and MSBuild have many differences when targetting UWP, so use MSBuild to maximize existing compatibility
        set(NINJA_CAN_BE_USED OFF)
    endif()

    if(arg_GENERATOR)
        set(GENERATOR ${arg_GENERATOR})
    elseif(arg_PREFER_NINJA AND NINJA_CAN_BE_USED)
        set(GENERATOR "Ninja")
    elseif(VCPKG_CHAINLOAD_TOOLCHAIN_FILE OR (VCPKG_CMAKE_SYSTEM_NAME AND NOT _TARGETTING_UWP))
        set(GENERATOR "Ninja")

    elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "x86" AND VCPKG_PLATFORM_TOOLSET STREQUAL "v120")
        set(GENERATOR "Visual Studio 12 2013")
    elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64" AND VCPKG_PLATFORM_TOOLSET STREQUAL "v120")
        set(GENERATOR "Visual Studio 12 2013 Win64")
    elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm" AND VCPKG_PLATFORM_TOOLSET STREQUAL "v120")
        set(GENERATOR "Visual Studio 12 2013 ARM")

    elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "x86" AND VCPKG_PLATFORM_TOOLSET STREQUAL "v140")
        set(GENERATOR "Visual Studio 14 2015")
    elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64" AND VCPKG_PLATFORM_TOOLSET STREQUAL "v140")
        set(GENERATOR "Visual Studio 14 2015 Win64")
    elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm" AND VCPKG_PLATFORM_TOOLSET STREQUAL "v140")
        set(GENERATOR "Visual Studio 14 2015 ARM")

    elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "x86" AND VCPKG_PLATFORM_TOOLSET STREQUAL "v141")
        set(GENERATOR "Visual Studio 15 2017")
    elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64" AND VCPKG_PLATFORM_TOOLSET STREQUAL "v141")
        set(GENERATOR "Visual Studio 15 2017 Win64")
    elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm" AND VCPKG_PLATFORM_TOOLSET STREQUAL "v141")
        set(GENERATOR "Visual Studio 15 2017 ARM")
    elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64" AND VCPKG_PLATFORM_TOOLSET STREQUAL "v141")
        set(GENERATOR "Visual Studio 15 2017")
        set(ARCH "ARM64")

    elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "x86" AND VCPKG_PLATFORM_TOOLSET STREQUAL "v142")
        set(GENERATOR "Visual Studio 16 2019")
        set(ARCH "Win32")
    elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64" AND VCPKG_PLATFORM_TOOLSET STREQUAL "v142")
        set(GENERATOR "Visual Studio 16 2019")
        set(ARCH "x64")
    elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm" AND VCPKG_PLATFORM_TOOLSET STREQUAL "v142")
        set(GENERATOR "Visual Studio 16 2019")
        set(ARCH "ARM")
    elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64" AND VCPKG_PLATFORM_TOOLSET STREQUAL "v142")
        set(GENERATOR "Visual Studio 16 2019")
        set(ARCH "ARM64")

    else()
        if(NOT VCPKG_CMAKE_SYSTEM_NAME)
            set(VCPKG_CMAKE_SYSTEM_NAME Windows)
        endif()
        message(FATAL_ERROR "Unable to determine appropriate generator for: "
            "${VCPKG_CMAKE_SYSTEM_NAME}-${VCPKG_TARGET_ARCHITECTURE}-${VCPKG_PLATFORM_TOOLSET}")
    endif()

    # If we use Ninja, make sure it's on PATH
    if(GENERATOR STREQUAL "Ninja" AND NOT DEFINED ENV{VCPKG_FORCE_SYSTEM_BINARIES})
        vcpkg_find_acquire_program(NINJA)
        get_filename_component(NINJA_PATH ${NINJA} DIRECTORY)
        vcpkg_add_to_path("${NINJA_PATH}")
        list(APPEND arg_OPTIONS "-DCMAKE_MAKE_PROGRAM=${NINJA}")
    endif()

    file(REMOVE_RECURSE ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg)

    if(DEFINED VCPKG_CMAKE_SYSTEM_NAME)
        list(APPEND arg_OPTIONS "-DCMAKE_SYSTEM_NAME=${VCPKG_CMAKE_SYSTEM_NAME}")
        if(_TARGETTING_UWP AND NOT DEFINED VCPKG_CMAKE_SYSTEM_VERSION)
            set(VCPKG_CMAKE_SYSTEM_VERSION 10.0)
        elseif(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "Android" AND NOT DEFINED VCPKG_CMAKE_SYSTEM_VERSION)
            set(VCPKG_CMAKE_SYSTEM_VERSION 21)
        endif()
    endif()

    if(DEFINED VCPKG_CMAKE_SYSTEM_VERSION)
        list(APPEND arg_OPTIONS "-DCMAKE_SYSTEM_VERSION=${VCPKG_CMAKE_SYSTEM_VERSION}")
    endif()

    if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
        list(APPEND arg_OPTIONS -DBUILD_SHARED_LIBS=ON)
    elseif(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
        list(APPEND arg_OPTIONS -DBUILD_SHARED_LIBS=OFF)
    else()
        message(FATAL_ERROR
            "Invalid setting for VCPKG_LIBRARY_LINKAGE: \"${VCPKG_LIBRARY_LINKAGE}\". "
            "It must be \"static\" or \"dynamic\"")
    endif()

    macro(check_both_vars_are_set var1 var2)
        if((NOT DEFINED ${var1} OR NOT DEFINED ${var2}) AND (DEFINED ${var1} OR DEFINED ${var2}))
            message(FATAL_ERROR "Both ${var1} and ${var2} must be set.")
        endif()
    endmacro()

    check_both_vars_are_set(VCPKG_CXX_FLAGS_DEBUG VCPKG_C_FLAGS_DEBUG)
    check_both_vars_are_set(VCPKG_CXX_FLAGS_RELEASE VCPKG_C_FLAGS_RELEASE)
    check_both_vars_are_set(VCPKG_CXX_FLAGS VCPKG_C_FLAGS)

    set(VCPKG_SET_CHARSET_FLAG ON)
    if(arg_NO_CHARSET_FLAG)
        set(VCPKG_SET_CHARSET_FLAG OFF)
    endif()

    if(NOT VCPKG_CHAINLOAD_TOOLCHAIN_FILE)
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

    list(JOIN VCPKG_TARGET_ARCHITECTURE "\;" target_architecure_string)
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
        "-DVCPKG_TARGET_ARCHITECTURE=${target_architecure_string}"
        "-DCMAKE_INSTALL_LIBDIR:STRING=lib"
        "-DCMAKE_INSTALL_BINDIR:STRING=bin"
        "-D_VCPKG_ROOT_DIR=${VCPKG_ROOT_DIR}"
        "-D_VCPKG_INSTALLED_DIR=${_VCPKG_INSTALLED_DIR}"
        "-DVCPKG_MANIFEST_INSTALL=OFF"
    )

    if(DEFINED ARCH)
        list(APPEND arg_OPTIONS
            "-A${ARCH}"
        )
    endif()

    # Sets configuration variables for macOS builds
    foreach(config_var  INSTALL_NAME_DIR OSX_DEPLOYMENT_TARGET OSX_SYSROOT OSX_ARCHITECTURES)
        if(DEFINED VCPKG_${config_var})
            list(JOIN VCPKG_${config_var} "\;" config_var_value)
            list(APPEND arg_OPTIONS "-DCMAKE_${config_var}=${config_var_value}")
        endif()
    endforeach()

    set(rel_command
        ${CMAKE_COMMAND} ${arg_SOURCE_PATH} "${arg_OPTIONS}" "${arg_OPTIONS_RELEASE}"
        -G ${GENERATOR}
        -DCMAKE_BUILD_TYPE=Release
        -DCMAKE_INSTALL_PREFIX=${CURRENT_PACKAGES_DIR})
    set(dbg_command
        ${CMAKE_COMMAND} ${arg_SOURCE_PATH} "${arg_OPTIONS}" "${arg_OPTIONS_DEBUG}"
        -G ${GENERATOR}
        -DCMAKE_BUILD_TYPE=Debug
        -DCMAKE_INSTALL_PREFIX=${CURRENT_PACKAGES_DIR}/debug)

    if(NINJA_HOST AND CMAKE_HOST_WIN32 AND NOT arg_DISABLE_PARALLEL_CONFIGURE)
        list(APPEND arg_OPTIONS "-DCMAKE_DISABLE_SOURCE_CHANGES=ON")

        vcpkg_find_acquire_program(NINJA)
        get_filename_component(NINJA_PATH ${NINJA} DIRECTORY)
        vcpkg_add_to_path("${NINJA_PATH}")

        #parallelize the configure step
        set(_contents
            "rule CreateProcess\n  command = $process\n\n"
        )

        macro(_build_cmakecache whereat build_type)
            set(${build_type}_line "build ${whereat}/CMakeCache.txt: CreateProcess\n  process = cmd /c \"cd ${whereat} &&")
            foreach(arg ${${build_type}_command})
                set(${build_type}_line "${${build_type}_line} \"${arg}\"")
            endforeach()
            set(_contents "${_contents}${${build_type}_line}\"\n\n")
        endmacro()

        if(NOT DEFINED VCPKG_BUILD_TYPE)
            _build_cmakecache(".." "rel")
            _build_cmakecache("../../${TARGET_TRIPLET}-dbg" "dbg")
        elseif(VCPKG_BUILD_TYPE STREQUAL "release")
            _build_cmakecache(".." "rel")
        elseif(VCPKG_BUILD_TYPE STREQUAL "debug")
            _build_cmakecache("../../${TARGET_TRIPLET}-dbg" "dbg")
        endif()

        file(MAKE_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/vcpkg-parallel-configure)
        file(WRITE ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/vcpkg-parallel-configure/build.ninja "${_contents}")

        message(STATUS "${configuring_message}")
        vcpkg_execute_required_process(
            COMMAND ninja -v
            WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/vcpkg-parallel-configure
            LOGNAME ${arg_LOGNAME}
        )
        
        list(APPEND config_logs
            "${CURRENT_BUILDTREES_DIR}/${arg_LOGNAME}-out.log"
            "${CURRENT_BUILDTREES_DIR}/${arg_LOGNAME}-err.log")
    else()
        if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
            message(STATUS "${configuring_message}-dbg")
            file(MAKE_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg)
            vcpkg_execute_required_process(
                COMMAND ${dbg_command}
                WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg
                LOGNAME ${arg_LOGNAME}-dbg
            )
            list(APPEND config_logs
                "${CURRENT_BUILDTREES_DIR}/${arg_LOGNAME}-dbg-out.log"
                "${CURRENT_BUILDTREES_DIR}/${arg_LOGNAME}-dbg-err.log")
        endif()

        if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
            message(STATUS "${configuring_message}-rel")
            file(MAKE_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel)
            vcpkg_execute_required_process(
                COMMAND ${rel_command}
                WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel
                LOGNAME ${arg_LOGNAME}-rel
            )
            list(APPEND config_logs
                "${CURRENT_BUILDTREES_DIR}/${arg_LOGNAME}-rel-out.log"
                "${CURRENT_BUILDTREES_DIR}/${arg_LOGNAME}-rel-err.log")
        endif()
    endif()
    
    # Check unused variables
    set(all_unused_variables)
    foreach(config_log IN LISTS config_logs)
        if (NOT EXISTS "${config_log}")
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
Please recheck them and remove the unnecessary options from the `vcpkg_configure_cmake` call.
If these options should still be passed for whatever reason, please use the `MAYBE_UNUSED_VARIABLES` argument.")
    endif()

    if(NOT arg_Z_GET_CMAKE_VARS_USAGE)
        set(Z_VCPKG_CMAKE_GENERATOR "${GENERATOR}" PARENT_SCOPE)
    endif()
endfunction()
