#.rst:
# .. command:: vcpkg_build_msbuild
#
#  Build a msbuild-based project.
#
#  ::
#  vcpkg_build_msbuild(PROJECT_PATH <sln_project_path>
#                      [RELEASE_CONFIGURATION <release_configuration>] # (default = "Release")
#                      [DEBUG_CONFIGURATION <debug_configuration>] @ (default = "Debug")
#                      [PLATFORM <platform>] # (default = "${TRIPLET_SYSTEM_ARCH}")
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
#  ``DEBUG_CONFIGURATION``
#    The configuration (``/p:Configuration`` msbuild parameter)
#    used for Debug builds.
#  ``PLATFORM``
#    The platform (``/p:Platform`` msbuild parameter)
#    used for the build.
#  ``OPTIONS``
#    The options passed to msbuild for all builds.
#  ``OPTIONS_RELEASE``
#    The options passed to msbuild for Release builds.
#  ``OPTIONS_DEBUG``
#    The options passed to msbuild for Debug builds.
#

function(vcpkg_build_msbuild)
    cmake_parse_arguments(_csc "" "PROJECT_PATH;RELEASE_CONFIGURATION;DEBUG_CONFIGURATION;PLATFORM" "OPTIONS;OPTIONS_RELEASE;OPTIONS_DEBUG" ${ARGN})

    if(NOT DEFINED _csc_RELEASE_CONFIGURATION)
        set(_csc_RELEASE_CONFIGURATION Release)
    endif()
    if(NOT DEFINED _csc_DEBUG_CONFIGURATION)
        set(_csc_DEBUG_CONFIGURATION Debug)
    endif()
	if(NOT DEFINED _csc_PLATFORM)
        set(_csc_PLATFORM ${TRIPLET_SYSTEM_ARCH})
    endif()

    message(STATUS "Building ${_csc_PROJECT_PATH} for Release")
    file(MAKE_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel)
    vcpkg_execute_required_process(
        COMMAND msbuild ${_csc_PROJECT_PATH} ${_csc_OPTIONS} ${_csc_OPTIONS_RELEASE}
            /p:Configuration=${_csc_RELEASE_CONFIGURATION}
            /p:Platform=${_csc_PLATFORM}
            /p:VCPkgLocalAppDataDisabled=true
        WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel
        LOGNAME build-${TARGET_TRIPLET}-rel
    )

    message(STATUS "Building ${_csc_PROJECT_PATH} for Debug")
    file(MAKE_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg)
    vcpkg_execute_required_process(
        COMMAND msbuild ${_csc_PROJECT_PATH} ${_csc_OPTIONS} ${_csc_OPTIONS_DEBUG}
            /p:Configuration=${_csc_DEBUG_CONFIGURATION}
            /p:Platform=${_csc_PLATFORM}
            /p:VCPkgLocalAppDataDisabled=true
        WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg
        LOGNAME build-${TARGET_TRIPLET}-dbg
    )
endfunction()