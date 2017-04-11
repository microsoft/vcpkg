#.rst:
# .. command:: vcpkg_build_msbuild
#
#  Build a msbuild-based project.
#
#  ::
#  vcpkg_build_msbuild(PROJECT_PATH <sln_project_path>
#                      [RELEASE_CONFIGURATION <release_configuration>] # (default = "Release")
#                      [DEBUG_CONFIGURATION <debug_configuration>] @ (default = "Debug")
#                      [TARGET_PLATFORM_VERSION <windows_target_platform_version>]
#                      [PLATFORM <platform>] # (default = "${TRIPLET_SYSTEM_ARCH}")
#                      [PLATFORM_TOOLSET <platform_toolset>] # (default = "${VCPKG_PLATFORM_TOOLSET}")
#                      [OPTIONS arg1 [arg2 ...]]
#                      [OPTIONS_RELEASE arg1 [arg2 ...]]
#                      [OPTIONS_DEBUG arg1 [arg2 ...]]
#                      )
#
#  ``PROJECT_PATH``
#    The path to the *.sln msbuild project file.
#  ``RELEASE_CONFIGURATION``
#    The configuration (``/p:Configuration`` msbuild parameter)
#    used for Release builds.
#  ``DEBUG_CONFIGURATION``
#    The configuration (``/p:Configuration`` msbuild parameter)
#    used for Debug builds.
#  ``TARGET_PLATFORM_VERSION``
#    The WindowsTargetPlatformVersion (``/p:WindowsTargetPlatformVersion`` msbuild parameter)
#  ``TARGET``
#    The MSBuild target to build. (``/t:<TARGET>``)
#  ``PLATFORM``
#    The platform (``/p:Platform`` msbuild parameter)
#    used for the build.
#  ``PLATFORM_TOOLSET``
#    The platform toolset (``/p:PlatformToolset`` msbuild parameter)
#    used for the build.
#  ``OPTIONS``
#    The options passed to msbuild for all builds.
#  ``OPTIONS_RELEASE``
#    The options passed to msbuild for Release builds.
#  ``OPTIONS_DEBUG``
#    The options passed to msbuild for Debug builds.
#


function(vcpkg_build_msbuild)
    cmake_parse_arguments(_csc "" "PROJECT_PATH;RELEASE_CONFIGURATION;DEBUG_CONFIGURATION;PLATFORM;PLATFORM_TOOLSET;TARGET_PLATFORM_VERSION;TARGET" "OPTIONS;OPTIONS_RELEASE;OPTIONS_DEBUG" ${ARGN})

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
endfunction()
