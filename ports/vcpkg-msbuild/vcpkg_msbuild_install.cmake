function(vcpkg_msbuild_install)
    cmake_parse_arguments(
        PARSE_ARGV 0
        "arg"
        "SKIP_CLEAN"
        "SOURCE_PATH;PROJECT_SUBPATH;INCLUDES_SUBPATH;LICENSE_SUBPATH;RELEASE_CONFIGURATION;DEBUG_CONFIGURATION;PLATFORM;TARGET;LANGUAGE"
        "OPTIONS;OPTIONS_RELEASE;OPTIONS_DEBUG;DEPENDENT_PKGCONFIG;ADDITIONAL_LIBS_DEBUG;ADDITIONAL_LIBS_RELEASE"
    )

    if(DEFINED arg_UNPARSED_ARGUMENTS)
        message(WARNING "vcpkg_install_msbuild was passed extra arguments: ${arg_UNPARSED_ARGUMENTS}")
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

    list(APPEND arg_OPTIONS
        "/t:${arg_TARGET}"
        "/p:Platform=${arg_PLATFORM}"
        "/p:PlatformToolset=${arg_PLATFORM_TOOLSET}"
        "/p:VCPkgLocalAppDataDisabled=true"
        "/p:UseIntelMKL=No"
        "/p:VcpkgTriplet=${TARGET_TRIPLET}"
        "/p:VcpkgInstalledDir=${_VCPKG_INSTALLED_DIR}"
        "/p:VcpkgManifestInstall=false"
        "/p:UseMultiToolTask=true"
        "/p:MultiProcMaxCount=${VCPKG_CONCURRENCY}"
        "/p:EnforceProcessCountAcrossBuilds=true"
        "/m:${VCPKG_CONCURRENCY}"
    )

    if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
        # Disable LTCG for static libraries because this setting introduces ABI incompatibility between minor compiler versions
        # TODO: Add a way for the user to override this if they want to opt-in to incompatibility
        list(APPEND arg_OPTIONS "/p:WholeProgramOptimization=false")
    endif()

    vcpkg_msbuild_create_props(OUTPUT_PROPS props_file 
                               LANGUAGE ${arg_LANGUAGE}
                               RELEASE_CONFIGURATION "${arg_RELEASE_CONFIGURATION}"
                               DEBUG_CONFIGURATION "${arg_DEBUG_CONFIGURATION}"
                               DEPENDENT_PKGCONFIG ${arg_DEPENDENT_PKGCONFIG}
                               ADDITIONAL_LIBS_DEBUG ${arg_ADDITIONAL_LIBS_DEBUG}
                               ADDITIONAL_LIBS_RELEASE ${arg_ADDITIONAL_LIBS_RELEASE})

    set(source_path_suffix "")
    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
        message(STATUS "Building ${arg_PROJECT_SUBPATH} for Release")
        file(REMOVE_RECURSE "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel")
        file(MAKE_DIRECTORY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel")
        file(COPY "${arg_SOURCE_PATH}/" DESTINATION "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel")
        set(source_copy_path "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/${source_path_suffix}")
        vcpkg_msbuild_inject_props(INJECT_PROPS "${props_file}" PROJECT_TO_INJECT "${source_copy_path}/${arg_PROJECT_SUBPATH}")
        vcpkg_execute_required_process(
            COMMAND msbuild "${source_copy_path}/${arg_PROJECT_SUBPATH}"
                "/p:Configuration=${arg_RELEASE_CONFIGURATION}"
                ${arg_OPTIONS}
                ${arg_OPTIONS_RELEASE}
            WORKING_DIRECTORY "${source_copy_path}"
            LOGNAME "build-${TARGET_TRIPLET}-rel"
        )
        file(GLOB_RECURSE libs "${source_copy_path}/*.lib")
        file(GLOB_RECURSE dlls "${source_copy_path}/*.dll")
        file(GLOB_RECURSE exes "${source_copy_path}/*.exe")
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

    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
        message(STATUS "Building ${arg_PROJECT_SUBPATH} for Debug")
        file(REMOVE_RECURSE "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg")
        file(MAKE_DIRECTORY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg")
        file(COPY "${arg_SOURCE_PATH}/" DESTINATION "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg")
        set(source_copy_path "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/${source_path_suffix}")
        vcpkg_msbuild_inject_props(INJECT_PROPS "${props_file}" PROJECT_TO_INJECT "${source_copy_path}/${arg_PROJECT_SUBPATH}")
        vcpkg_execute_required_process(
            COMMAND msbuild "${source_copy_path}/${arg_PROJECT_SUBPATH}"
                "/p:Configuration=${arg_DEBUG_CONFIGURATION}"
                ${arg_OPTIONS}
                ${arg_OPTIONS_DEBUG}
            WORKING_DIRECTORY "${source_copy_path}"
            LOGNAME "build-${TARGET_TRIPLET}-dbg"
        )
        file(GLOB_RECURSE libs "${source_copy_path}/*.lib")
        file(GLOB_RECURSE dlls "${source_copy_path}/*.dll")
        if(NOT libs STREQUAL "")
            file(COPY ${libs} DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib")
        endif()
        if(NOT dlls STREQUAL "")
            file(COPY ${dlls} DESTINATION "${CURRENT_PACKAGES_DIR}/debug/bin")
        endif()
    endif()

    vcpkg_copy_pdbs()

    if(NOT arg_SKIP_CLEAN)
        vcpkg_clean_msbuild()
    endif()

    if(DEFINED arg_INCLUDES_SUBPATH)
        file(COPY "${arg_SOURCE_PATH}/${arg_INCLUDES_SUBPATH}/"
            DESTINATION "${CURRENT_PACKAGES_DIR}/include/"
        )
    endif()

    if(DEFINED arg_LICENSE_SUBPATH)
        file(INSTALL "${arg_SOURCE_PATH}/${arg_LICENSE_SUBPATH}"
            DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
            RENAME copyright
        )
    endif()
endfunction()
