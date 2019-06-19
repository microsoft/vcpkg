## # vcpkg_configure_cmake
##
## Configure CMake for Debug and Release builds of a project.
##
## ## Usage
## ```cmake
## vcpkg_configure_cmake(
##     SOURCE_PATH <${SOURCE_PATH}>
##     [PREFER_NINJA]
##     [GENERATOR <"NMake Makefiles">]
##     [OPTIONS <-DUSE_THIS_IN_ALL_BUILDS=1>...]
##     [OPTIONS_RELEASE <-DOPTIMIZE=1>...]
##     [OPTIONS_DEBUG <-DDEBUGGABLE=1>...]
## )
## ```
##
## ## Parameters
## ### SOURCE_PATH
## Specifies the directory containing the `CMakeLists.txt`. By convention, this is usually set in the portfile as the variable `SOURCE_PATH`.
##
## ### PREFER_NINJA
## Indicates that, when available, Vcpkg should use Ninja to perform the build. This should be specified unless the port is known to not work under Ninja.
##
## ### DISABLE_PARALLEL_CONFIGURE
## Disables running the CMake configure step in parallel.
##
## This is needed for libraries which write back into their source directory during configure.
##
## ### GENERATOR
## Specifies the precise generator to use.
##
## This is useful if some project-specific buildsystem has been wrapped in a cmake script that won't perform an actual build. If used for this purpose, it should be set to "NMake Makefiles".
##
## ### OPTIONS
## Additional options passed to CMake during the configuration.
##
## ### OPTIONS_RELEASE
## Additional options passed to CMake during the Release configuration. These are in addition to `OPTIONS`.
##
## ### OPTIONS_DEBUG
## Additional options passed to CMake during the Debug configuration. These are in addition to `OPTIONS`.
##
## ## Notes
## This command supplies many common arguments to CMake. To see the full list, examine the source.
##
## ## Examples
##
## * [zlib](https://github.com/Microsoft/vcpkg/blob/master/ports/zlib/portfile.cmake)
## * [cpprestsdk](https://github.com/Microsoft/vcpkg/blob/master/ports/cpprestsdk/portfile.cmake)
## * [poco](https://github.com/Microsoft/vcpkg/blob/master/ports/poco/portfile.cmake)
## * [opencv](https://github.com/Microsoft/vcpkg/blob/master/ports/opencv/portfile.cmake)
function(vcpkg_configure_cmake)
    cmake_parse_arguments(_csc "PREFER_NINJA;DISABLE_PARALLEL_CONFIGURE" "SOURCE_PATH;GENERATOR" "OPTIONS;OPTIONS_DEBUG;OPTIONS_RELEASE" ${ARGN})

    if(NOT VCPKG_PLATFORM_TOOLSET)
        message(FATAL_ERROR "Vcpkg has been updated with VS2017 support, however you need to rebuild vcpkg.exe by re-running bootstrap-vcpkg.bat\n")
    endif()

    if(DEFINED ENV{PROCESSOR_ARCHITEW6432})
        set(_csc_HOST_ARCHITECTURE $ENV{PROCESSOR_ARCHITEW6432})
    else()
        set(_csc_HOST_ARCHITECTURE $ENV{PROCESSOR_ARCHITECTURE})
    endif()

    if(CMAKE_HOST_WIN32)
        set(_PATHSEP ";")
    else()
        set(_PATHSEP ":")
    endif()

    set(NINJA_CAN_BE_USED ON) # Ninja as generator
    set(NINJA_HOST ON) # Ninja as parallel configurator
    if(_csc_HOST_ARCHITECTURE STREQUAL "x86")
        # Prebuilt ninja binaries are only provided for x64 hosts
        set(NINJA_CAN_BE_USED OFF)
        set(NINJA_HOST OFF)
    elseif(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
        # Ninja and MSBuild have many differences when targetting UWP, so use MSBuild to maximize existing compatibility
        set(NINJA_CAN_BE_USED OFF)
    endif()

    if(_csc_GENERATOR)
        set(GENERATOR ${_csc_GENERATOR})
    elseif(_csc_PREFER_NINJA AND NINJA_CAN_BE_USED)
        set(GENERATOR "Ninja")
    elseif(VCPKG_CHAINLOAD_TOOLCHAIN_FILE OR (VCPKG_CMAKE_SYSTEM_NAME AND NOT VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore"))
        set(GENERATOR "Ninja")

    elseif(VCPKG_TARGET_ARCHITECTURE MATCHES "x86" AND VCPKG_PLATFORM_TOOLSET MATCHES "v120")
        set(GENERATOR "Visual Studio 12 2013")
    elseif(VCPKG_TARGET_ARCHITECTURE MATCHES "x64" AND VCPKG_PLATFORM_TOOLSET MATCHES "v120")
        set(GENERATOR "Visual Studio 12 2013 Win64")
    elseif(VCPKG_TARGET_ARCHITECTURE MATCHES "arm" AND VCPKG_PLATFORM_TOOLSET MATCHES "v120")
        set(GENERATOR "Visual Studio 12 2013 ARM")

    elseif(VCPKG_TARGET_ARCHITECTURE MATCHES "x86" AND VCPKG_PLATFORM_TOOLSET MATCHES "v140")
        set(GENERATOR "Visual Studio 14 2015")
    elseif(VCPKG_TARGET_ARCHITECTURE MATCHES "x64" AND VCPKG_PLATFORM_TOOLSET MATCHES "v140")
        set(GENERATOR "Visual Studio 14 2015 Win64")
    elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm" AND VCPKG_PLATFORM_TOOLSET MATCHES "v140")
        set(GENERATOR "Visual Studio 14 2015 ARM")

    elseif(VCPKG_TARGET_ARCHITECTURE MATCHES "x86" AND VCPKG_PLATFORM_TOOLSET MATCHES "v141")
        set(GENERATOR "Visual Studio 15 2017")
    elseif(VCPKG_TARGET_ARCHITECTURE MATCHES "x64" AND VCPKG_PLATFORM_TOOLSET MATCHES "v141")
        set(GENERATOR "Visual Studio 15 2017 Win64")
    elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm" AND VCPKG_PLATFORM_TOOLSET MATCHES "v141")
        set(GENERATOR "Visual Studio 15 2017 ARM")
    elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64" AND VCPKG_PLATFORM_TOOLSET MATCHES "v141")
        set(GENERATOR "Visual Studio 15 2017")
        set(ARCH "ARM64")

    elseif(VCPKG_TARGET_ARCHITECTURE MATCHES "x86" AND VCPKG_PLATFORM_TOOLSET MATCHES "v142")
        set(GENERATOR "Visual Studio 16 2019")
        set(ARCH "Win32")
    elseif(VCPKG_TARGET_ARCHITECTURE MATCHES "x64" AND VCPKG_PLATFORM_TOOLSET MATCHES "v142")
        set(GENERATOR "Visual Studio 16 2019")
        set(ARCH "x64")
    elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm" AND VCPKG_PLATFORM_TOOLSET MATCHES "v142")
        set(GENERATOR "Visual Studio 16 2019")
        set(ARCH "ARM")
    elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64" AND VCPKG_PLATFORM_TOOLSET MATCHES "v142")
        set(GENERATOR "Visual Studio 16 2019")
        set(ARCH "ARM64")

    else()
        if(NOT VCPKG_CMAKE_SYSTEM_NAME)
            set(VCPKG_CMAKE_SYSTEM_NAME Windows)
        endif()
        message(FATAL_ERROR "Unable to determine appropriate generator for: ${VCPKG_CMAKE_SYSTEM_NAME}-${VCPKG_TARGET_ARCHITECTURE}-${VCPKG_PLATFORM_TOOLSET}")
    endif()

    # If we use Ninja, make sure it's on PATH
    if(GENERATOR STREQUAL "Ninja")
        vcpkg_find_acquire_program(NINJA)
        get_filename_component(NINJA_PATH ${NINJA} DIRECTORY)
        set(ENV{PATH} "$ENV{PATH}${_PATHSEP}${NINJA_PATH}")
        list(APPEND _csc_OPTIONS "-DCMAKE_MAKE_PROGRAM=${NINJA}")
    endif()

    file(REMOVE_RECURSE ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg)

    if(DEFINED VCPKG_CMAKE_SYSTEM_NAME)
        list(APPEND _csc_OPTIONS "-DCMAKE_SYSTEM_NAME=${VCPKG_CMAKE_SYSTEM_NAME}")
        if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore" AND NOT DEFINED VCPKG_CMAKE_SYSTEM_VERSION)
            set(VCPKG_CMAKE_SYSTEM_VERSION 10.0)
        endif()
    endif()
    if(DEFINED VCPKG_CMAKE_SYSTEM_VERSION)
        list(APPEND _csc_OPTIONS "-DCMAKE_SYSTEM_VERSION=${VCPKG_CMAKE_SYSTEM_VERSION}")
    endif()

    if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
        list(APPEND _csc_OPTIONS -DBUILD_SHARED_LIBS=ON)
    elseif(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
        list(APPEND _csc_OPTIONS -DBUILD_SHARED_LIBS=OFF)
    else()
        message(FATAL_ERROR "Invalid setting for VCPKG_LIBRARY_LINKAGE: \"${VCPKG_LIBRARY_LINKAGE}\". It must be \"static\" or \"dynamic\"")
    endif()

    if((NOT DEFINED VCPKG_CXX_FLAGS_DEBUG AND NOT DEFINED VCPKG_C_FLAGS_DEBUG) OR
        (DEFINED VCPKG_CXX_FLAGS_DEBUG AND DEFINED VCPKG_C_FLAGS_DEBUG))
    else()
        message(FATAL_ERROR "You must set both the VCPKG_CXX_FLAGS_DEBUG and VCPKG_C_FLAGS_DEBUG")
    endif()
    if((NOT DEFINED VCPKG_CXX_FLAGS_RELEASE AND NOT DEFINED VCPKG_C_FLAGS_RELEASE) OR
        (DEFINED VCPKG_CXX_FLAGS_RELEASE AND DEFINED VCPKG_C_FLAGS_RELEASE))
    else()
        message(FATAL_ERROR "You must set both the VCPKG_CXX_FLAGS_RELEASE and VCPKG_C_FLAGS_RELEASE")
    endif()
    if((NOT DEFINED VCPKG_CXX_FLAGS AND NOT DEFINED VCPKG_C_FLAGS) OR
        (DEFINED VCPKG_CXX_FLAGS AND DEFINED VCPKG_C_FLAGS))
    else()
        message(FATAL_ERROR "You must set both the VCPKG_CXX_FLAGS and VCPKG_C_FLAGS")
    endif()

    if(VCPKG_CHAINLOAD_TOOLCHAIN_FILE)
        list(APPEND _csc_OPTIONS "-DVCPKG_CHAINLOAD_TOOLCHAIN_FILE=${VCPKG_CHAINLOAD_TOOLCHAIN_FILE}")
    elseif(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore" OR NOT DEFINED VCPKG_CMAKE_SYSTEM_NAME)
        list(APPEND _csc_OPTIONS "-DVCPKG_CHAINLOAD_TOOLCHAIN_FILE=${VCPKG_ROOT_DIR}/scripts/toolchains/windows.cmake")
    elseif(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "Linux")
        list(APPEND _csc_OPTIONS "-DVCPKG_CHAINLOAD_TOOLCHAIN_FILE=${VCPKG_ROOT_DIR}/scripts/toolchains/linux.cmake")
    elseif(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "Android")
        list(APPEND _csc_OPTIONS "-DVCPKG_CHAINLOAD_TOOLCHAIN_FILE=${VCPKG_ROOT_DIR}/scripts/toolchains/android.cmake")
    elseif(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "Darwin")
        list(APPEND _csc_OPTIONS "-DVCPKG_CHAINLOAD_TOOLCHAIN_FILE=${VCPKG_ROOT_DIR}/scripts/toolchains/osx.cmake")
    elseif(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "FreeBSD")
        list(APPEND _csc_OPTIONS "-DVCPKG_CHAINLOAD_TOOLCHAIN_FILE=${VCPKG_ROOT_DIR}/scripts/toolchains/freebsd.cmake")
    endif()

    list(APPEND _csc_OPTIONS
        "-DVCPKG_TARGET_TRIPLET=${TARGET_TRIPLET}"
        "-DVCPKG_PLATFORM_TOOLSET=${VCPKG_PLATFORM_TOOLSET}"
        "-DCMAKE_EXPORT_NO_PACKAGE_REGISTRY=ON"
        "-DCMAKE_FIND_PACKAGE_NO_PACKAGE_REGISTRY=ON"
        "-DCMAKE_FIND_PACKAGE_NO_SYSTEM_PACKAGE_REGISTRY=ON"
        "-DCMAKE_INSTALL_SYSTEM_RUNTIME_LIBS_SKIP=TRUE"
        "-DCMAKE_VERBOSE_MAKEFILE=ON"
        "-DVCPKG_APPLOCAL_DEPS=OFF"
        "-DCMAKE_TOOLCHAIN_FILE=${VCPKG_ROOT_DIR}/scripts/buildsystems/vcpkg.cmake"
        "-DCMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION=ON"
        "-DVCPKG_CXX_FLAGS=${VCPKG_CXX_FLAGS}"
        "-DVCPKG_CXX_FLAGS_RELEASE=${VCPKG_CXX_FLAGS_RELEASE}"
        "-DVCPKG_CXX_FLAGS_DEBUG=${VCPKG_CXX_FLAGS_DEBUG}"
        "-DVCPKG_C_FLAGS=${VCPKG_C_FLAGS}"
        "-DVCPKG_C_FLAGS_RELEASE=${VCPKG_C_FLAGS_RELEASE}"
        "-DVCPKG_C_FLAGS_DEBUG=${VCPKG_C_FLAGS_DEBUG}"
        "-DVCPKG_CRT_LINKAGE=${VCPKG_CRT_LINKAGE}"
        "-DVCPKG_LINKER_FLAGS=${VCPKG_LINKER_FLAGS}"
        "-DVCPKG_TARGET_ARCHITECTURE=${VCPKG_TARGET_ARCHITECTURE}"
        "-DCMAKE_INSTALL_LIBDIR:STRING=lib"
        "-DCMAKE_INSTALL_BINDIR:STRING=bin"
    )

    if(DEFINED ARCH)
        list(APPEND _csc_OPTIONS
            "-A${ARCH}"
        )
    endif()

    # Sets configuration variables for macOS builds
    if(DEFINED VCPKG_INSTALL_NAME_DIR)
        list(APPEND _csc_OPTIONS "-DCMAKE_INSTALL_NAME_DIR=${VCPKG_INSTALL_NAME_DIR}")
    endif()
    if(DEFINED VCPKG_OSX_DEPLOYMENT_TARGET)
        list(APPEND _csc_OPTIONS "-DCMAKE_OSX_DEPLOYMENT_TARGET=${VCPKG_OSX_DEPLOYMENT_TARGET}")
    endif()
    if(DEFINED VCPKG_OSX_SYSROOT)
        list(APPEND _csc_OPTIONS "-DCMAKE_OSX_SYSROOT=${VCPKG_OSX_SYSROOT}")
    endif()

    set(rel_command
        ${CMAKE_COMMAND} ${_csc_SOURCE_PATH} "${_csc_OPTIONS}" "${_csc_OPTIONS_RELEASE}"
        -G ${GENERATOR}
        -DCMAKE_BUILD_TYPE=Release
        -DCMAKE_INSTALL_PREFIX=${CURRENT_PACKAGES_DIR})
    set(dbg_command
        ${CMAKE_COMMAND} ${_csc_SOURCE_PATH} "${_csc_OPTIONS}" "${_csc_OPTIONS_DEBUG}"
        -G ${GENERATOR}
        -DCMAKE_BUILD_TYPE=Debug
        -DCMAKE_INSTALL_PREFIX=${CURRENT_PACKAGES_DIR}/debug)

    if(NINJA_HOST AND CMAKE_HOST_SYSTEM_NAME STREQUAL "Windows" AND NOT _csc_DISABLE_PARALLEL_CONFIGURE)

        vcpkg_find_acquire_program(NINJA)
        get_filename_component(NINJA_PATH ${NINJA} DIRECTORY)
        set(ENV{PATH} "$ENV{PATH}${_PATHSEP}${NINJA_PATH}")

        #parallelize the configure step
        set(_contents
            "rule CreateProcess\n  command = $process\n\n"
        )

        if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
            set(rel_line "build ../CMakeCache.txt: CreateProcess\n  process = cmd /c \"cd .. &&")
            foreach(arg ${rel_command})
                set(rel_line "${rel_line} \"${arg}\"")
            endforeach()
            set(_contents "${_contents}${rel_line}\"\n\n")
        endif()

        if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
            set(dbg_line "build ../../${TARGET_TRIPLET}-dbg/CMakeCache.txt: CreateProcess\n  process = cmd /c \"cd ../../${TARGET_TRIPLET}-dbg &&")
            foreach(arg ${dbg_command})
                set(dbg_line "${dbg_line} \"${arg}\"")
            endforeach()
            set(_contents "${_contents}${dbg_line}\"\n\n")
        endif()

        file(MAKE_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/vcpkg-parallel-configure)
        file(WRITE ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/vcpkg-parallel-configure/build.ninja "${_contents}")

        message(STATUS "Configuring ${TARGET_TRIPLET}")
        vcpkg_execute_required_process(
            COMMAND ninja -v
            WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/vcpkg-parallel-configure
            LOGNAME config-${TARGET_TRIPLET}
        )
    else()
        if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
            message(STATUS "Configuring ${TARGET_TRIPLET}-dbg")
            file(MAKE_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg)
            vcpkg_execute_required_process(
                COMMAND ${dbg_command}
                WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg
                LOGNAME config-${TARGET_TRIPLET}-dbg
            )
        endif()

        if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
            message(STATUS "Configuring ${TARGET_TRIPLET}-rel")
            file(MAKE_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel)
            vcpkg_execute_required_process(
                COMMAND ${rel_command}
                WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel
                LOGNAME config-${TARGET_TRIPLET}-rel
            )
        endif()
    endif()

    set(_VCPKG_CMAKE_GENERATOR "${GENERATOR}" PARENT_SCOPE)
endfunction()
