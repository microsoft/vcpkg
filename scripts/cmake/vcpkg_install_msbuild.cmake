#[===[.md:
# vcpkg_install_msbuild

Build and install a msbuild-based project. This replaces `vcpkg_build_msbuild()`.

## Usage
```cmake
vcpkg_install_msbuild(
    SOURCE_PATH <${SOURCE_PATH}>
    PROJECT_SUBPATH <port.sln>
    [INCLUDES_SUBPATH <include>]
    [LICENSE_SUBPATH <LICENSE>]
    [RELEASE_CONFIGURATION <Release>]
    [DEBUG_CONFIGURATION <Debug>]
    [TARGET <Build>]
    [TARGET_PLATFORM_VERSION <10.0.15063.0>]
    [PLATFORM <${TRIPLET_SYSTEM_ARCH}>]
    [PLATFORM_TOOLSET <${VCPKG_PLATFORM_TOOLSET}>]
    [OPTIONS </p:ZLIB_INCLUDE_PATH=X>...]
    [OPTIONS_RELEASE </p:ZLIB_LIB=X>...]
    [OPTIONS_DEBUG </p:ZLIB_LIB=X>...]
    [USE_VCPKG_INTEGRATION]
    [ALLOW_ROOT_INCLUDES | REMOVE_ROOT_INCLUDES]
)
```

## Parameters
### SOURCE_PATH
The path to the root of the source tree.

Because MSBuild uses in-source builds, the source tree will be copied into a temporary location for the build. This
parameter is the base for that copy and forms the base for all XYZ_SUBPATH options.

### USE_VCPKG_INTEGRATION
Apply the normal `integrate install` integration for building the project.

By default, projects built with this command will not automatically link libraries or have header paths set.

### PROJECT_SUBPATH
The subpath to the solution (`.sln`) or project (`.vcxproj`) file relative to `SOURCE_PATH`.

### LICENSE_SUBPATH
The subpath to the license file relative to `SOURCE_PATH`.

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

* [libirecovery](https://github.com/Microsoft/vcpkg/blob/master/ports/libirecovery/portfile.cmake)
* [libfabric](https://github.com/Microsoft/vcpkg/blob/master/ports/libfabric/portfile.cmake)
#]===]

function(vcpkg_install_msbuild)
    cmake_parse_arguments(
        PARSE_ARGV 0
        "arg"
        "USE_VCPKG_INTEGRATION;ALLOW_ROOT_INCLUDES;REMOVE_ROOT_INCLUDES;SKIP_CLEAN"
        "SOURCE_PATH;PROJECT_SUBPATH;INCLUDES_SUBPATH;LICENSE_SUBPATH;RELEASE_CONFIGURATION;DEBUG_CONFIGURATION;PLATFORM;PLATFORM_TOOLSET;TARGET_PLATFORM_VERSION;TARGET"
        "OPTIONS;OPTIONS_RELEASE;OPTIONS_DEBUG"
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
        "/p:Platform=${arg_PLATFORM}"
        "/p:PlatformToolset=${arg_PLATFORM_TOOLSET}"
        "/p:VCPkgLocalAppDataDisabled=true"
        "/p:UseIntelMKL=No"
        "/p:WindowsTargetPlatformVersion=${arg_TARGET_PLATFORM_VERSION}"
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
            "/p:VcpkgApplocalDeps=false"
        )
    endif()

    get_filename_component(source_path_suffix "${arg_SOURCE_PATH}" NAME)
    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
        message(STATUS "Building ${arg_PROJECT_SUBPATH} for Release")
        file(REMOVE_RECURSE "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel")
        file(MAKE_DIRECTORY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel")
        file(COPY "${arg_SOURCE_PATH}" DESTINATION "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel")
        set(source_copy_path "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/${source_path_suffix}")
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
        file(COPY "${arg_SOURCE_PATH}" DESTINATION "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg")
        set(source_copy_path "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/${source_path_suffix}")
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
