function(vcpkg_build_msbuild)
    cmake_parse_arguments(
        PARSE_ARGV 0
        arg
        "USE_VCPKG_INTEGRATION"
        "PROJECT_PATH;RELEASE_CONFIGURATION;DEBUG_CONFIGURATION;PLATFORM;PLATFORM_TOOLSET;TARGET_PLATFORM_VERSION;TARGET"
        "OPTIONS;OPTIONS_RELEASE;OPTIONS_DEBUG"
    )

    if(DEFINED arg_UNPARSED_ARGUMENTS)
        message(WARNING "vcpkg_build_msbuild was passed extra arguments: ${arg_UNPARSED_ARGUMENTS}")
    endif()

    if(NOT DEFINED arg_RELEASE_CONFIGURATION)
        set(arg_RELEASE_CONFIGURATION Release)
    endif()
    if(NOT DEFINED arg_DEBUG_CONFIGURATION)
        set(arg_DEBUG_CONFIGURATION Debug)
    endif()
    if(NOT DEFINED arg_PLATFORM)
        set(arg_PLATFORM "${TRIPLET_SYSTEM_ARCH}")
    endif()
    if(NOT DEFINED arg_PLATFORM_TOOLSET)
        set(arg_PLATFORM_TOOLSET "${VCPKG_PLATFORM_TOOLSET}")
    endif()
    if(NOT DEFINED arg_TARGET_PLATFORM_VERSION)
        vcpkg_get_windows_sdk(arg_TARGET_PLATFORM_VERSION)
    endif()
    if(NOT DEFINED arg_TARGET)
        set(arg_TARGET Rebuild)
    endif()

    list(APPEND arg_OPTIONS
        "/t:${arg_TARGET}"
        "/p:Platform=${arg_PLATFORM}"
        "/p:PlatformToolset=${arg_PLATFORM_TOOLSET}"
        "/p:VCPkgLocalAppDataDisabled=true"
        "/p:UseIntelMKL=No"
        "/p:WindowsTargetPlatformVersion=${arg_TARGET_PLATFORM_VERSION}"
        "/p:VcpkgManifestInstall=false"
        "/p:VcpkgManifestEnabled=false"
        "/m"
    )

    if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
        # Disable LTCG for static libraries because this setting introduces ABI incompatibility between minor compiler versions
        # TODO: Add a way for the user to override this if they want to opt-in to incompatibility
        list(APPEND arg_OPTIONS "/p:WholeProgramOptimization=false")
    endif()

    if(arg_USE_VCPKG_INTEGRATION)
        list(
            APPEND arg_OPTIONS
            "/p:ForceImportBeforeCppTargets=${SCRIPTS}/buildsystems/msbuild/vcpkg.targets"
            "/p:VcpkgTriplet=${TARGET_TRIPLET}"
            "/p:VcpkgInstalledDir=${_VCPKG_INSTALLED_DIR}"
        )
    else()
        list(APPEND arg_OPTIONS "/p:VcpkgEnabled=false")
    endif()

    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
        message(STATUS "Building ${arg_PROJECT_PATH} for Release")
        file(MAKE_DIRECTORY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel")
        vcpkg_execute_required_process(
            COMMAND msbuild "${arg_PROJECT_PATH}"
                "/p:Configuration=${arg_RELEASE_CONFIGURATION}"
                ${arg_OPTIONS}
                ${arg_OPTIONS_RELEASE}
            WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel"
            LOGNAME "build-${TARGET_TRIPLET}-rel"
        )
    endif()

    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
        message(STATUS "Building ${arg_PROJECT_PATH} for Debug")
        file(MAKE_DIRECTORY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg")
        vcpkg_execute_required_process(
            COMMAND msbuild "${arg_PROJECT_PATH}"
                "/p:Configuration=${arg_DEBUG_CONFIGURATION}"
                ${arg_OPTIONS}
                ${arg_OPTIONS_DEBUG}
            WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg"
            LOGNAME "build-${TARGET_TRIPLET}-dbg"
        )
    endif()
endfunction()
