## # vcpkg_build_msbuild
##
## Build a msbuild-based project. Deprecated in favor of `vcpkg_install_msbuild()`.
##
## ## Usage
## ```cmake
## vcpkg_build_msbuild(
##     PROJECT_PATH <${SOURCE_PATH}/port.sln>
##     [RELEASE_CONFIGURATION <Release>]
##     [DEBUG_CONFIGURATION <Debug>]
##     [TARGET <Build>]
##     [TARGET_PLATFORM_VERSION <10.0.15063.0>]
##     [PLATFORM <${TRIPLET_SYSTEM_ARCH}>]
##     [PLATFORM_TOOLSET <${VCPKG_PLATFORM_TOOLSET}>]
##     [OPTIONS </p:ZLIB_INCLUDE_PATH=X>...]
##     [OPTIONS_RELEASE </p:ZLIB_LIB=X>...]
##     [OPTIONS_DEBUG </p:ZLIB_LIB=X>...]
##     [USE_VCPKG_INTEGRATION]
## )
## ```
##
## ## Parameters
## ### USE_VCPKG_INTEGRATION
## Apply the normal `integrate install` integration for building the project.
##
## By default, projects built with this command will not automatically link libraries or have header paths set.
##
## ### PROJECT_PATH
## The path to the solution (`.sln`) or project (`.vcxproj`) file.
##
## ### RELEASE_CONFIGURATION
## The configuration (``/p:Configuration`` msbuild parameter) used for Release builds.
##
## ### DEBUG_CONFIGURATION
## The configuration (``/p:Configuration`` msbuild parameter)
## used for Debug builds.
##
## ### TARGET_PLATFORM_VERSION
## The WindowsTargetPlatformVersion (``/p:WindowsTargetPlatformVersion`` msbuild parameter)
##
## ### TARGET
## The MSBuild target to build. (``/t:<TARGET>``)
##
## ### PLATFORM
## The platform (``/p:Platform`` msbuild parameter) used for the build.
##
## ### PLATFORM_TOOLSET
## The platform toolset (``/p:PlatformToolset`` msbuild parameter) used for the build.
##
## ### OPTIONS
## Additional options passed to msbuild for all builds.
##
## ### OPTIONS_RELEASE
## Additional options passed to msbuild for Release builds. These are in addition to `OPTIONS`.
##
## ### OPTIONS_DEBUG
## Additional options passed to msbuild for Debug builds. These are in addition to `OPTIONS`.
##
## ## Examples
##
## * [chakracore](https://github.com/Microsoft/vcpkg/blob/master/ports/chakracore/portfile.cmake)
## * [cppunit](https://github.com/Microsoft/vcpkg/blob/master/ports/cppunit/portfile.cmake)

function(vcpkg_build_msbuild)
    cmake_parse_arguments(
        _csc
        "USE_VCPKG_INTEGRATION"
        "PROJECT_PATH;RELEASE_CONFIGURATION;DEBUG_CONFIGURATION;PLATFORM;PLATFORM_TOOLSET;TARGET_PLATFORM_VERSION;TARGET"
        "OPTIONS;OPTIONS_RELEASE;OPTIONS_DEBUG"
        ${ARGN}
    )

    if(NOT DEFINED _csc_RELEASE_CONFIGURATION)
        set(_csc_RELEASE_CONFIGURATION Release)
    endif()
    if(NOT DEFINED _csc_DEBUG_CONFIGURATION)
        set(_csc_DEBUG_CONFIGURATION Debug)
    endif()
    if(NOT DEFINED _csc_PLATFORM)
        set(_csc_PLATFORM ${TRIPLET_SYSTEM_ARCH})
    endif()
    if(NOT DEFINED _csc_PLATFORM_TOOLSET)
        set(_csc_PLATFORM_TOOLSET ${VCPKG_PLATFORM_TOOLSET})
    endif()
    if(NOT DEFINED _csc_TARGET_PLATFORM_VERSION)
        vcpkg_get_windows_sdk(_csc_TARGET_PLATFORM_VERSION)
    endif()
    if(NOT DEFINED _csc_TARGET)
        set(_csc_TARGET Rebuild)
    endif()

    list(APPEND _csc_OPTIONS
        /t:${_csc_TARGET}
        /p:Platform=${_csc_PLATFORM}
        /p:PlatformToolset=${_csc_PLATFORM_TOOLSET}
        /p:VCPkgLocalAppDataDisabled=true
        /p:UseIntelMKL=No
        /p:WindowsTargetPlatformVersion=${_csc_TARGET_PLATFORM_VERSION}
        /m
    )

    if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
        # Disable LTCG for static libraries because this setting introduces ABI incompatibility between minor compiler versions
        # TODO: Add a way for the user to override this if they want to opt-in to incompatibility
        list(APPEND _csc_OPTIONS /p:WholeProgramOptimization=false)
    endif()

    if(_csc_USE_VCPKG_INTEGRATION)
        list(
            APPEND _csc_OPTIONS
            /p:ForceImportBeforeCppTargets=${VCPKG_ROOT_DIR}/scripts/buildsystems/msbuild/vcpkg.targets
            "/p:VcpkgTriplet=${TARGET_TRIPLET}"
        )
    endif()

    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
        message(STATUS "Building ${_csc_PROJECT_PATH} for Release")
        file(MAKE_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel)
        vcpkg_execute_required_process(
            COMMAND msbuild ${_csc_PROJECT_PATH}
                /p:Configuration=${_csc_RELEASE_CONFIGURATION}
                ${_csc_OPTIONS}
                ${_csc_OPTIONS_RELEASE}
            WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel
            LOGNAME build-${TARGET_TRIPLET}-rel
        )
    endif()

    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
        message(STATUS "Building ${_csc_PROJECT_PATH} for Debug")
        file(MAKE_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg)
        vcpkg_execute_required_process(
            COMMAND msbuild ${_csc_PROJECT_PATH}
                /p:Configuration=${_csc_DEBUG_CONFIGURATION}
                ${_csc_OPTIONS}
                ${_csc_OPTIONS_DEBUG}
            WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg
            LOGNAME build-${TARGET_TRIPLET}-dbg
        )
    endif()
endfunction()
