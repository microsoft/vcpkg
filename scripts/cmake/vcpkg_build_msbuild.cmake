#/p:ForceImportBeforeCppTargets=
#/p:ForceImportAfterCppTargets=
#/p:CustomBeforeMicrosoftCommonTargets
#/p:CustomAferMicrosoftCommonTargets
#CustomBeforeMicrosoftCommonProps
#CustomBeforeMicrosoftCommonTargets
#CustomAfterMicrosoftCommonProps
#CustomAfterMicrosoftCommonTargets
##
# ForceImportAfterCppDefaultProps
# ForceImportBeforeCppProps
# ForceImportAfterCppProps
# ForceImportBeforeCppTargets
# ForceImportAfterCppTargets
# -noAutoResponse
# -maxCpuCount: COUNT

#Directory.Build.props
#Directory.Build.targets
# https://docs.microsoft.com/en-us/dotnet/api/microsoft.visualstudio.vcprojectengine.vcclcompilertool.compileas?view=visualstudiosdk-2022
#https://docs.microsoft.com/en-us/visualstudio/msbuild/customize-your-build?view=vs-2022
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
    if(DEFINED arg_USE_VCPKG_INTEGRATION)
        message(WARNING "Usage of USE_VCPKG_INTEGRATION is deprecated! Please remove it!")
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
        "/m"
        "/p:PlatformToolset=${arg_PLATFORM_TOOLSET}"
        "/p:WindowsTargetPlatformVersion=${arg_TARGET_PLATFORM_VERSION}"
    )

    if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
        # Disable LTCG for static libraries because this setting introduces ABI incompatibility between minor compiler versions
        # TODO: Add a way for the user to override this if they want to opt-in to incompatibility
        list(APPEND arg_OPTIONS "/p:WholeProgramOptimization=false")
    endif()

    z_vcpkg_get_cmake_vars(cmake_vars_file)
    include("${cmake_vars_file}")
    cmake_path(GET "${arg_PROJECT_PATH}" PARENT_PATH project_path)
    configure_file("${SCRIPTS}/buildsystems/msbuild/vcpkg_msbuild.targets.in" "${project_path}/Directory.Build.targets")

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
