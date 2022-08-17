function(vcpkg_install_msbuild)
    cmake_parse_arguments(
        PARSE_ARGV 0
        "arg"
        "USE_VCPKG_INTEGRATION;ALLOW_ROOT_INCLUDES;REMOVE_ROOT_INCLUDES;SKIP_CLEAN"
        "SOURCE_PATH;PROJECT_SUBPATH;INCLUDES_SUBPATH;LICENSE_SUBPATH;RELEASE_CONFIGURATION;DEBUG_CONFIGURATION;PLATFORM;PLATFORM_TOOLSET;TARGET_PLATFORM_VERSION;TARGET"
        "OPTIONS;OPTIONS_RELEASE;OPTIONS_DEBUG;ADDITIONAL_LIBS;ADDITIONAL_LIBS_RELEASE;ADDITIONAL_LIBS_DEBUG;ADDITIONAL_PROPS;ADDITIONAL_TARGETS"
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
    if(NOT DEFINED arg_TARGET_PLATFORM_VERSION)
        vcpkg_get_windows_sdk(arg_TARGET_PLATFORM_VERSION)
    endif()
    if(NOT DEFINED arg_TARGET)
        set(arg_TARGET Rebuild)
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

    list(APPEND arg_ADDITIONAL_LIBS_RELEASE ${arg_ADDITIONAL_LIBS})
    list(APPEND arg_ADDITIONAL_LIBS_DEBUG ${arg_ADDITIONAL_LIBS})
    list(APPEND VCPKG_MSBUILD_INCLUDE_DIRS_DEBUG "%(AdditionalIncludeDirectories)" "${CURRENT_INSTALLED_DIR}/include" ${MSBUILD_INCLUDE_DIRS_DEBUG})
    list(APPEND VCPKG_MSBUILD_INCLUDE_DIRS_RELEASE "%(AdditionalIncludeDirectories)" "${CURRENT_INSTALLED_DIR}/include" ${MSBUILD_INCLUDE_DIRS_RELEASE} )
    list(APPEND VCPKG_MSBUILD_LIBRARY_DIRS_DEBUG "%(AdditionalLibraryDirectories)" "${CURRENT_INSTALLED_DIR}/debug/lib" ${MSBUILD_LIBRARIES_DIRS_DEBUG})
    list(APPEND VCPKG_MSBUILD_LIBRARY_DIRS_RELEASE "%(AdditionalLibraryDirectories)" "${CURRENT_INSTALLED_DIR}/lib" ${MSBUILD_LIBRARIES_DIRS_RELEASE})
    list(APPEND VCPKG_MSBUILD_ADDITIONAL_LIBS_DEBUG "%(AdditionalDependencies)" ${arg_ADDITIONAL_LIBS_DEBUG} ${MSBUILD_LIBRARIES_DEBUG})
    list(APPEND VCPKG_MSBUILD_ADDITIONAL_LIBS_RELEASE "%(AdditionalDependencies)" ${arg_ADDITIONAL_LIBS_RELEASE} ${MSBUILD_LIBRARIES_RELEASE})

    foreach(prop_file IN LISTS arg_ADDITIONAL_PROPS)
        list(APPEND VCPKG_MSBUILD_ADDITIONAL_PROPS_XML "<Import Project=\"${prop_file}\" />")
    endforeach()
    foreach(target_file IN LISTS arg_ADDITIONAL_TARGETS)
        list(APPEND VCPKG_MSBUILD_ADDITIONAL_TARGETS_XML "<Import Project=\"${target_file}\" />")
    endforeach()
    
    if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
        # Disable LTCG for static libraries because this setting introduces ABI incompatibility between minor compiler versions
        # TODO: Add a way for the user to override this if they want to opt-in to incompatibility
        list(APPEND arg_OPTIONS "/p:WholeProgramOptimization=false")
    endif()

    if(arg_USE_VCPKG_INTEGRATION)
        list(APPEND arg_OPTIONS
            "/p:ForceImportBeforeCppTargets=${SCRIPTS}/buildsystems/msbuild/vcpkg.targets"
            "/p:VcpkgApplocalDeps=false"
        )
    endif()

    z_vcpkg_get_cmake_vars(cmake_vars_file)
    include("${cmake_vars_file}")

    get_filename_component(source_path_suffix "${arg_SOURCE_PATH}" NAME)
    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
        message(STATUS "Building ${arg_PROJECT_SUBPATH} for Release")
        file(REMOVE_RECURSE "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel")
        file(MAKE_DIRECTORY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel")
        file(COPY "${arg_SOURCE_PATH}" DESTINATION "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel")
        set(source_copy_path "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/${source_path_suffix}")
        set(source_project_subpath "${source_copy_path}/${arg_PROJECT_SUBPATH}")
        cmake_path(GET source_project_subpath PARENT_PATH project_path)
        file(RELATIVE_PATH project_root "${project_path}" "${source_copy_path}")
        #configure_file("${SCRIPTS}/buildsystems/msbuild/vcpkg_msbuild.targets.in" "${project_path}/Directory.Build.targets")
        configure_file("${SCRIPTS}/buildsystems/msbuild/vcpkg_msbuild.targets.in" "${project_path}/vcpkg_msbuild.targets")
        #configure_file("${SCRIPTS}/buildsystems/msbuild/vcpkg_msbuild.props.in" "${project_path}/Directory.Build.props")
        configure_file("${SCRIPTS}/buildsystems/msbuild/vcpkg_msbuild.props.in" "${project_path}/vcpkg_msbuild.props")
        vcpkg_execute_required_process(
            COMMAND msbuild "${source_copy_path}/${arg_PROJECT_SUBPATH}"
                "/p:Configuration=${arg_RELEASE_CONFIGURATION}"
                "/p:ForceImportAfterCppProps=${project_path}/vcpkg_msbuild.props"
                "/p:ForceImportAfterCppTargets=${project_path}/vcpkg_msbuild.targets"
                "-detailedSummary:True"
                #"-v:diag"
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
        file(COPY "${arg_SOURCE_PATH}" DESTINATION "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg")
        set(source_copy_path "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/${source_path_suffix}")
        set(source_project_subpath "${source_copy_path}/${arg_PROJECT_SUBPATH}")
        cmake_path(GET source_project_subpath PARENT_PATH project_path)
        file(RELATIVE_PATH project_root "${project_path}" "${source_copy_path}")
        configure_file("${SCRIPTS}/buildsystems/msbuild/vcpkg_msbuild.targets.in" "${project_path}/Directory.Build.targets")
        configure_file("${SCRIPTS}/buildsystems/msbuild/vcpkg_msbuild.targets.in" "${project_path}/vcpkg_msbuild.targets")
        configure_file("${SCRIPTS}/buildsystems/msbuild/vcpkg_msbuild.props.in" "${project_path}/Directory.Build.props")
        configure_file("${SCRIPTS}/buildsystems/msbuild/vcpkg_msbuild.props.in" "${project_path}/vcpkg_msbuild.props")
        vcpkg_execute_required_process(
            COMMAND msbuild "${source_copy_path}/${arg_PROJECT_SUBPATH}"
                "/p:Configuration=${arg_DEBUG_CONFIGURATION}"
                "/p:ForceImportAfterCppProps=${project_path}/vcpkg_msbuild.props"
                "/p:ForceImportAfterCppTargets=${project_path}/vcpkg_msbuild.targets"
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
        file(GLOB root_includes
            LIST_DIRECTORIES false
            "${CURRENT_PACKAGES_DIR}/include/*")
        if(NOT root_includes STREQUAL "")
            if(arg_REMOVE_ROOT_INCLUDES)
                file(REMOVE ${root_includes})
            elseif(arg_ALLOW_ROOT_INCLUDES)
            else()
                message(FATAL_ERROR "Top-level files were found in ${CURRENT_PACKAGES_DIR}/include; this may indicate a problem with the call to `vcpkg_install_msbuild()`.\nTo avoid conflicts with other libraries, it is recommended to not put includes into the root `include/` directory.\nPass either ALLOW_ROOT_INCLUDES or REMOVE_ROOT_INCLUDES to handle these files.\n")
            endif()
        endif()
    endif()

    if(DEFINED arg_LICENSE_SUBPATH)
        file(INSTALL "${arg_SOURCE_PATH}/${arg_LICENSE_SUBPATH}"
            DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
            RENAME copyright
        )
    endif()
endfunction()
