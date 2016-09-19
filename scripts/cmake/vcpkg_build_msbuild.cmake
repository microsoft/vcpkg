function(vcpkg_build_msbuild)
    cmake_parse_arguments(_csc "" "PROJECT_PATH;RELEASE_CONFIGURATION;DEBUG_CONFIGURATION" "OPTIONS;OPTIONS_DEBUG;OPTIONS_RELEASE" ${ARGN})

    if(NOT DEFINED _csc_RELEASE_CONFIGURATION)
        set(_csc_RELEASE_CONFIGURATION Release)
    endif()
    if(NOT DEFINED _csc_DEBUG_CONFIGURATION)
        set(_csc_DEBUG_CONFIGURATION Debug)
    endif()

    message(STATUS "Building ${_csc_PROJECT_PATH} for Release")
    file(MAKE_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel)
    vcpkg_execute_required_process(
        COMMAND msbuild ${_csc_PROJECT_PATH} ${_csc_OPTIONS} ${_csc_OPTIONS_RELEASE}
            /p:Configuration=${_csc_RELEASE_CONFIGURATION}
            /p:Platform=${TRIPLET_SYSTEM_ARCH}
            /p:VCPkgLocalAppDataDisabled=true
        WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel
        LOGNAME build-${TARGET_TRIPLET}-rel
    )

    message(STATUS "Building ${_csc_PROJECT_PATH} for Debug")
    file(MAKE_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg)
    vcpkg_execute_required_process(
        COMMAND msbuild ${_csc_PROJECT_PATH} ${_csc_OPTIONS} ${_csc_OPTIONS_DEBUG}
            /p:Configuration=${_csc_DEBUG_CONFIGURATION}
            /p:Platform=${TRIPLET_SYSTEM_ARCH}
            /p:VCPkgLocalAppDataDisabled=true
        WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg
        LOGNAME build-${TARGET_TRIPLET}-dbg
    )
endfunction()