function(vcpkg_msbuild_install)
    cmake_parse_arguments(
        PARSE_ARGV 0
        "arg"
        "CLEAN;NO_TOOLCHAIN_PROPS;NO_INSTALL"
        "SOURCE_PATH;PROJECT_SUBPATH;RELEASE_CONFIGURATION;DEBUG_CONFIGURATION;PLATFORM;TARGET"
        "OPTIONS;OPTIONS_RELEASE;OPTIONS_DEBUG;DEPENDENT_PKGCONFIG;ADDITIONAL_LIBS;ADDITIONAL_LIBS_DEBUG;ADDITIONAL_LIBS_RELEASE"
    )

    if(DEFINED arg_UNPARSED_ARGUMENTS)
        message(WARNING "${CMAKE_CURRENT_FUNCTION} was passed extra arguments: ${arg_UNPARSED_ARGUMENTS}")
    endif()
    if(NOT DEFINED arg_RELEASE_CONFIGURATION)
        set(arg_RELEASE_CONFIGURATION Release)
    endif()
    if(NOT DEFINED arg_DEBUG_CONFIGURATION)
        set(arg_DEBUG_CONFIGURATION Debug)
    endif()

    if(NOT DEFINED arg_PLATFORM)
        if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
            set(arg_PLATFORM x64)
        elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
            set(arg_PLATFORM Win32)
        elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm")
            set(arg_PLATFORM ARM)
        elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
            set(arg_PLATFORM arm64)
        else()
            message(FATAL_ERROR "Unsupported target architecture")
        endif()
    endif()
    if(NOT DEFINED arg_PLATFORM_TOOLSET)
        set(arg_PLATFORM_TOOLSET "${VCPKG_PLATFORM_TOOLSET}")
    endif()

    if(NOT DEFINED arg_TARGET)
        set(arg_TARGET Rebuild)
    endif()
    if(DEFINED arg_ADDITIONAL_LIBS)
        list(APPEND arg_ADDITIONAL_LIBS_DEBUG ${arg_ADDITIONAL_LIBS})
        list(APPEND arg_ADDITIONAL_LIBS_RELEASE ${arg_ADDITIONAL_LIBS})
    endif()

    vcpkg_get_windows_sdk(arg_TARGET_PLATFORM_VERSION)

    if(NOT arg_NO_TOOLCHAIN_PROPS)
        file(RELATIVE_PATH project_root "${arg_SOURCE_PATH}/${arg_PROJECT_SUBPATH}" "${arg_SOURCE_PATH}") # required by z_vcpkg_msbuild_create_props
        z_vcpkg_msbuild_create_props(OUTPUT_PROPS props_file
                                     OUTPUT_TARGETS target_file
                                     RELEASE_CONFIGURATION "${arg_RELEASE_CONFIGURATION}"
                                     DEBUG_CONFIGURATION "${arg_DEBUG_CONFIGURATION}"
                                     DEPENDENT_PKGCONFIG ${arg_DEPENDENT_PKGCONFIG}
                                     ADDITIONAL_LIBS_DEBUG ${arg_ADDITIONAL_LIBS_DEBUG}
                                     ADDITIONAL_LIBS_RELEASE ${arg_ADDITIONAL_LIBS_RELEASE})
        list(APPEND arg_OPTIONS         
            "/p:ForceImportAfterCppProps=${props_file}"
            "/p:ForceImportAfterCppTargets=${target_file}"
        )
    endif()


    list(APPEND arg_OPTIONS
        "/t:${arg_TARGET}"
        "/p:UseMultiToolTask=true"
        "/p:MultiProcMaxCount=${VCPKG_CONCURRENCY}"
        "/p:EnforceProcessCountAcrossBuilds=true"
        "/m:${VCPKG_CONCURRENCY}"
        "-maxCpuCount:${VCPKG_CONCURRENCY}"
        # other Properties 
        "/p:Platform=${arg_PLATFORM}"
        "/p:PlatformToolset=${arg_PLATFORM_TOOLSET}"
        "/p:WindowsTargetPlatformVersion=${arg_TARGET_PLATFORM_VERSION}"
        # vcpkg properties
        "/p:VcpkgApplocalDeps=false"
        "/p:VcpkgManifestInstall=false"
        "/p:VcpkgManifestEnabled=false"
        "/p:VcpkgEnabled=false"
        "/p:VcpkgTriplet=${TARGET_TRIPLET}"
        "/p:VcpkgInstalledDir=${_VCPKG_INSTALLED_DIR}"
    )

    if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
        # Disable LTCG for static libraries because this setting introduces ABI incompatibility between minor compiler versions
        # TODO: Add a way for the user to override this if they want to opt-in to incompatibility
        list(APPEND arg_OPTIONS "/p:WholeProgramOptimization=false")
    endif()

    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
        message(STATUS "Building ${arg_PROJECT_SUBPATH} for Release")
        set(working_dir "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel")
        file(REMOVE_RECURSE "${working_dir}")
        file(MAKE_DIRECTORY "${working_dir}")
        file(COPY "${arg_SOURCE_PATH}/" DESTINATION "${working_dir}")
        vcpkg_execute_required_process(
            COMMAND msbuild "${working_dir}/${arg_PROJECT_SUBPATH}"
                "/p:Configuration=${arg_RELEASE_CONFIGURATION}"
                ${arg_OPTIONS}
                ${arg_OPTIONS_RELEASE}
            WORKING_DIRECTORY "${working_dir}"
            LOGNAME "build-${TARGET_TRIPLET}-rel"
        )
        if(NOT arg_NO_INSTALL)
            file(GLOB_RECURSE libs "${working_dir}/*.lib")
            file(GLOB_RECURSE dlls "${working_dir}/*.dll")
            file(GLOB_RECURSE exes "${working_dir}/*.exe")
            if(NOT libs STREQUAL "")
                file(COPY ${libs} DESTINATION "${CURRENT_PACKAGES_DIR}/lib")
            endif()
            if(NOT dlls STREQUAL "")
                file(COPY ${dlls} DESTINATION "${CURRENT_PACKAGES_DIR}/bin")
            endif()
            if(NOT exes STREQUAL "")
                file(COPY ${exes} DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}")
                vcpkg_copy_tool_dependencies("${CURRENT_PACKAGES_DIR}/tools/${PORT}")
            endif()
        endif()
    endif()

    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
        message(STATUS "Building ${arg_PROJECT_SUBPATH} for Debug")
        set(working_dir "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg")
        file(REMOVE_RECURSE "${working_dir}")
        file(MAKE_DIRECTORY "${working_dir}")
        file(COPY "${arg_SOURCE_PATH}/" DESTINATION "${working_dir}")
        vcpkg_execute_required_process(
            COMMAND msbuild "${working_dir}/${arg_PROJECT_SUBPATH}"
                "/p:Configuration=${arg_DEBUG_CONFIGURATION}"
                ${arg_OPTIONS}
                ${arg_OPTIONS_DEBUG}
            WORKING_DIRECTORY "${working_dir}"
            LOGNAME "build-${TARGET_TRIPLET}-dbg"
        )
        if(NOT arg_NO_INSTALL)
            file(GLOB_RECURSE libs "${working_dir}/*.lib")
            file(GLOB_RECURSE dlls "${working_dir}/*.dll")
            if(NOT libs STREQUAL "")
                file(COPY ${libs} DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib")
            endif()
            if(NOT dlls STREQUAL "")
                file(COPY ${dlls} DESTINATION "${CURRENT_PACKAGES_DIR}/debug/bin")
            endif()
        endif()
    endif()

    vcpkg_copy_pdbs()

    if(arg_CLEAN)
        vcpkg_clean_msbuild()
    endif()

endfunction()
