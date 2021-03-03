#[===[.md:
# vcpkg_msbuild_install

Build and install a msbuild-based project.

```cmake
vcpkg_msbuild_install(
    SOURCE_PATH <source-path>
    PROJECT_FILE <path-to-solution-or-project>
    [TARGET <target>]
    [INCLUDES_DIRECTORY <path-to-include-dir>]

    [RELEASE_CONFIGURATION <configuration>]
    [DEBUG_CONFIGURATION <configuration>]
    [OPTIONS <option>...]
    [OPTIONS_RELEASE <option>...]
    [OPTIONS_DEBUG <option>...]

    [PLATFORM_VERSION <platform-version>]
    [PLATFORM_ARCHITECTURE <architecture>]
    [PLATFORM_TOOLSET <toolset>]

    [USE_VCPKG_INTEGRATION]
    [ADD_BIN_TO_PATH]
    [DISABLE_PARALLEL]
    [SKIP_CLEAN]
    [ALLOW_ROOT_INCLUDES]
)
```

`vcpkg_msbuild_install()` is the only function one needs when
building an MSBuild project: unlike other build systems,
which have a configure step followed by an install step,
`vcpkg_msbuild_install` is complete in and of itself.
The only required parameters are `SOURCE_PATH` and `PROJECT_FILE`;
`SOURCE_PATH` should be set to `${SOURCE_PATH}` by convention,
while the `PROJECT_FILE` should be a relative path to the project or solution file.

One thing which should be noted is that because MSBuild uses in-source builds,
the source tree will be copied into a temporary location for the build.

There are a few important

### INCLUDES_SUBPATH
The subpath to the includes directory relative to `SOURCE_PATH`.

This parameter should be a directory and should not end in a trailing slash.

### ALLOW_ROOT_INCLUDES
Indicates that top-level include files (e.g. `include/zlib.h`) should be allowed.

### REMOVE_ROOT_INCLUDES
Indicates that top-level include files (e.g. `include/Makefile.am`) should be removed.

### SKIP_CLEAN
Indicates that the intermediate files should not be removed.

Ports using this option should later call [`vcpkg_clean_msbuild()`](vcpkg_clean_msbuild.md) to manually clean up.

By default, vcpkg is integrated into these builds so that dependencies can be found;
in order to disable the integration, one can pass the `DISABLE_VCPKG_INTEGRATION`
option.


### RELEASE_CONFIGURATION
The configuration (``/p:Configuration`` msbuild parameter) used for Release builds.

### DEBUG_CONFIGURATION
The configuration (``/p:Configuration`` msbuild parameter) used for Debug builds.

### TARGET_PLATFORM_VERSION
The WindowsTargetPlatformVersion (``/p:WindowsTargetPlatformVersion`` msbuild parameter)

### TARGET
The MSBuild target to build. (``/t:<TARGET>``)

### PLATFORM
The platform (``/p:Platform`` msbuild parameter) used for the build.

### PLATFORM_TOOLSET
The platform toolset (``/p:PlatformToolset`` msbuild parameter) used for the build.

### OPTIONS
Additional options passed to msbuild for all builds.

### OPTIONS_RELEASE
Additional options passed to msbuild for Release builds. These are in addition to `OPTIONS`.

### OPTIONS_DEBUG
Additional options passed to msbuild for Debug builds. These are in addition to `OPTIONS`.

## Examples

* [xalan-c](https://github.com/Microsoft/vcpkg/blob/master/ports/xalan-c/portfile.cmake)
* [libimobiledevice](https://github.com/Microsoft/vcpkg/blob/master/ports/libimobiledevice/portfile.cmake)
#]===]
if(Z_VCPKG_MSBUILD_INSTALL_GUARD)
    return()
endif()
set(Z_VCPKG_MSBUILD_INSTALL_GUARD ON CACHE INTERNAL "guard variable")

# NOTES:
# * set /MP (add to end of ENV{CL})
# * Add Multi-ToolTask to msbuild https://github.com/microsoft/vcpkg/pull/15478/commits/9845ea575eec309c01a905e8bf4b9b7f81248158 line 127
#   * breaks python
# * remove applocal deps, switch to adding bin to path if that flag passed
# * directory.build.props, directory.build.targets
#   Basically, these will get read from the directory tree above if they don't exist
#   so create them if they are not already created in the source directory
#   these should be <Project></Project>
# additional improvements (probably outside scope)
# * we should provide a way for the triplet file to inject
#   props & targets
#   (in the same way that we allow triplets to inject toolchains)
#   (cc directory.build.props/directory.build.targets)
#   between the <Project></Project>, add <Import Project="path" />s
# * if we have the ability to inject proper msbuild code (not just passing /p switches),
#   we might be able to fix /MT vs /MD, static vs dynamic build

function(vcpkg_msbuild_install)
    cmake_parse_arguments(PARSE_ARGV 0 "arg"
        "USE_VCPKG_INTEGRATION;ADD_BIN_TO_PATH;DISABLE_PARALLEL;SKIP_CLEAN;ALLOW_ROOT_INCLUDES"
        "SOURCE_PATH;PROJECT_FILE;TARGET;INCLUDES_DIRECTORY;RELEASE_CONFIGURATION;DEBUG_CONFIGURATION;PLATFORM_VERSION;PLATFORM_ARCHITECTURE;PLATFORM_TOOLSET"
        "OPTIONS;OPTIONS_RELEASE;OPTIONS_DEBUG"
    )

    if(DEFINED arg_UNPARSED_ARGUMENTS)
        message(FATAL_ERROR "vcpkg_install_msbuild was passed extra arguments: ${arg_UNPARSED_ARGUMENTS}")
    endif()

    foreach(required_arg IN ITEMS SOURCE_PATH PROJECT_FILE)
        if(NOT DEFINED arg_${required_arg})
            message(FATAL_ERROR "${required_arg} must be set")
        endif()
    endforeach()

    foreach(rel_arg IN ITEMS PROJECT_FILE INCLUDES_DIRECTORY)
        if(DEFINED arg_${rel_arg} AND IS_ABSOLUTE "${arg_${rel_arg}}")
            message(FATAL_ERROR "${rel_arg} is an absolute path; it should be relative to the root of the sources.
    ${rel_arg}: ${arg_${rel_arg}}")
        endif()
    endforeach()

    if(NOT DEFINED arg_RELEASE_CONFIGURATION)
        set(arg_RELEASE_CONFIGURATION Release)
    endif()
    if(NOT DEFINED arg_DEBUG_CONFIGURATION)
        set(arg_DEBUG_CONFIGURATION Debug)
    endif()
    if(NOT DEFINED arg_PLATFORM_ARCHITECTURE)
        if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
            set(arg_PLATFORM_ARCHITECTURE x64)
        elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
            set(arg_PLATFORM_ARCHITECTURE Win32)
        elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "ARM")
            set(arg_PLATFORM_ARCHITECTURE ARM)
        elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
            set(arg_PLATFORM_ARCHITECTURE arm64)
        else()
            message(FATAL_ERROR "Unsupported target architecture")
        endif()
    endif()
    if(NOT DEFINED arg_PLATFORM_TOOLSET)
        set(arg_PLATFORM_TOOLSET "${VCPKG_PLATFORM_TOOLSET}")
    endif()
    if(NOT DEFINED arg_PLATFORM_VERSION)
        vcpkg_get_windows_sdk(arg_PLATFORM_VERSION)
    endif()
    if(NOT DEFINED arg_TARGET)
        set(arg_TARGET Rebuild)
    endif()

    list(APPEND arg_OPTIONS
        "/t:${arg_TARGET}"
        "/p:Platform=${arg_PLATFORM_ARCHITECTURE}"
        "/p:PlatformToolset=${arg_PLATFORM_TOOLSET}"
        "/p:VCPkgLocalAppDataDisabled=true"
        "/p:UseIntelMKL=No"
        "/p:WindowsTargetPlatformVersion=${arg_PLATFORM_VERSION}"
        "/p:VcpkgTriplet=${TARGET_TRIPLET}"
        "/p:VcpkgInstalledDir=${_VCPKG_INSTALLED_DIR}"
        "/p:VcpkgManifestInstall=false"
        "/m"
    )

    if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
        # Disable LTCG for static libraries because this setting introduces ABI incompatibility between minor compiler versions
        # TODO: Add a way for the user to override this if they want to opt-in to incompatibility
        list(APPEND arg_OPTIONS "/p:WholeProgramOptimization=false")
    endif()

    if(arg_USE_VCPKG_INTEGRATION)
        list(APPEND arg_OPTIONS
            "/p:ForceImportBeforeCppTargets=${SCRIPTS}/buildsystems/msbuild/vcpkg.targets"
            "/p:VcpkgApplocalDeps=false")
    endif()

    get_filename_component(source_path_suffix "${arg_SOURCE_PATH}" NAME)
    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
        message(STATUS "Building ${arg_PROJECT_FILE} for Release")
        file(REMOVE_RECURSE "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel")
        file(MAKE_DIRECTORY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel")
        file(COPY "${arg_SOURCE_PATH}" DESTINATION "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel")

        set(source_copy_path "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/${source_path_suffix}")
        vcpkg_execute_required_process(
            COMMAND msbuild "${source_copy_path}/${arg_PROJECT_FILE}"
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
            file(COPY ${libs}
                DESTINATION "${CURRENT_PACKAGES_DIR}/lib")
        endif()
        if(NOT dlls STREQUAL "")
            file(COPY ${dlls}
                DESTINATION "${CURRENT_PACKAGES_DIR}/bin")
        endif()

        set(tools "")
        foreach(exe IN LISTS exes)
            get_filename_component(exe_name "${exe}" NAME)
            string(REGEX REPLACE [[\.exe$]] "" tool_name "${exe_name}")
            list(APPEND tools "${tool_name}")
        endforeach()
        if(NOT tools STREQUAL "")
            vcpkg_copy_tools(TOOL_NAMES ${tools} SEARCH_DIR "${source_copy_path}")
        endif()
    endif()

    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
        message(STATUS "Building ${arg_PROJECT_FILE} for Debug")
        file(REMOVE_RECURSE "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg")
        file(MAKE_DIRECTORY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg")
        file(COPY "${arg_SOURCE_PATH}" DESTINATION "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg")

        set(source_copy_path "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/${source_path_suffix}")
        vcpkg_execute_required_process(
            COMMAND msbuild "${source_copy_path}/${arg_PROJECT_FILE}"
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
        vcpkg_msbuild_clean()
    endif()

    if(DEFINED arg_INCLUDES_DIRECTORY)
        file(COPY "${arg_SOURCE_PATH}/${arg_INCLUDES_DIRECTORY}/" DESTINATION "${CURRENT_PACKAGES_DIR}/include/")
        file(GLOB root_includes LIST_DIRECTORIES false "${CURRENT_PACKAGES_DIR}/include/*")
        if(NOT root_includes STREQUAL "")
            if(NOT ALLOW_ROOT_INCLUDES)
                message(FATAL_ERROR "
Top-level files were found in ${CURRENT_PACKAGES_DIR}/include; this may indicate a problem with the call to `vcpkg_install_msbuild()`.
To avoid conflicts with other libraries, it is recommended to not put includes into the root `include/` directory.
Pass ALLOW_ROOT_INCLUDES to allow these files to exist.")
            endif()
        endif()
    endif()
endfunction()
