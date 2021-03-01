#[===[.md:
# vcpkg_msbuild_install

Build and install a msbuild-based project.

```cmake
vcpkg_msbuild_install(
    SOURCE_PATH <source-path>
    PROJECT_FILE <path-to-solution-or-project>
    [INCLUDES_DIRECTORY <path-to-include-dir>]
    [RELEASE_CONFIGURATION <configuration>]
    [DEBUG_CONFIGURATION <configuration>]
    [TARGET <target>]
    [TARGET_PLATFORM_VERSION <platform-version>]
    [PLATFORM_ARCHITECTURE <architecture>]
    [PLATFORM_TOOLSET <toolset>]
    [DISABLE_VCPKG_INTEGRATION]
    [OPTIONS <option>...]
    [OPTIONS_RELEASE <option>...]
    [OPTIONS_DEBUG <option>...]
    [ALLOW_ROOT_INCLUDES | REMOVE_ROOT_INCLUDES]
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

include(vcpkg_clean_msbuild)

function(vcpkg_install_msbuild)
    cmake_parse_arguments(
        PARSE_ARGV 0
        _csc
        "DISABLE_VCPKG_INTEGRATION;ALLOW_ROOT_INCLUDES;REMOVE_ROOT_INCLUDES"
        "SOURCE_PATH;PROJECT_SUBPATH;INCLUDES_SUBPATH;LICENSE_SUBPATH;RELEASE_CONFIGURATION;DEBUG_CONFIGURATION;PLATFORM;PLATFORM_TOOLSET;TARGET_PLATFORM_VERSION;TARGET"
        "OPTIONS;OPTIONS_RELEASE;OPTIONS_DEBUG"
    )

    if(NOT DEFINED _csc_RELEASE_CONFIGURATION)
        set(_csc_RELEASE_CONFIGURATION Release)
    endif()
    if(NOT DEFINED _csc_DEBUG_CONFIGURATION)
        set(_csc_DEBUG_CONFIGURATION Debug)
    endif()
    if(NOT DEFINED _csc_PLATFORM)
        if(VCPKG_TARGET_ARCHITECTURE STREQUAL x64)
            set(_csc_PLATFORM  x64)
        elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL x86)
            set(_csc_PLATFORM  Win32)
        elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL ARM)
            set(_csc_PLATFORM  ARM)
        elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL arm64)
            set(_csc_PLATFORM  arm64)
        else()
            message(FATAL_ERROR "Unsupported target architecture")
        endif()
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
        /p:VcpkgTriplet=${TARGET_TRIPLET}
        "/p:VcpkgInstalledDir=${_VCPKG_INSTALLED_DIR}"
        /p:VcpkgManifestInstall=false
        /m
    )

    if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
        # Disable LTCG for static libraries because this setting introduces ABI incompatibility between minor compiler versions
        # TODO: Add a way for the user to override this if they want to opt-in to incompatibility
        list(APPEND _csc_OPTIONS /p:WholeProgramOptimization=false)
    endif()

    if(_csc_USE_VCPKG_INTEGRATION)
        list(APPEND _csc_OPTIONS /p:ForceImportBeforeCppTargets=${SCRIPTS}/buildsystems/msbuild/vcpkg.targets /p:VcpkgApplocalDeps=false)
    endif()

    get_filename_component(SOURCE_PATH_SUFFIX "${_csc_SOURCE_PATH}" NAME)
    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
        message(STATUS "Building ${_csc_PROJECT_SUBPATH} for Release")
        file(REMOVE_RECURSE ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel)
        file(MAKE_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel)
        file(COPY ${_csc_SOURCE_PATH} DESTINATION ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel)
        set(SOURCE_COPY_PATH ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/${SOURCE_PATH_SUFFIX})
        vcpkg_execute_required_process(
            COMMAND msbuild ${SOURCE_COPY_PATH}/${_csc_PROJECT_SUBPATH}
                /p:Configuration=${_csc_RELEASE_CONFIGURATION}
                ${_csc_OPTIONS}
                ${_csc_OPTIONS_RELEASE}
            WORKING_DIRECTORY ${SOURCE_COPY_PATH}
            LOGNAME build-${TARGET_TRIPLET}-rel
        )
        file(GLOB_RECURSE LIBS ${SOURCE_COPY_PATH}/*.lib)
        file(GLOB_RECURSE DLLS ${SOURCE_COPY_PATH}/*.dll)
        file(GLOB_RECURSE EXES ${SOURCE_COPY_PATH}/*.exe)
        if(LIBS)
            file(COPY ${LIBS} DESTINATION ${CURRENT_PACKAGES_DIR}/lib)
        endif()
        if(DLLS)
            file(COPY ${DLLS} DESTINATION ${CURRENT_PACKAGES_DIR}/bin)
        endif()
        if(EXES)
            file(COPY ${EXES} DESTINATION ${CURRENT_PACKAGES_DIR}/tools/${PORT})
            vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/${PORT})
        endif()
    endif()

    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
        message(STATUS "Building ${_csc_PROJECT_SUBPATH} for Debug")
        file(REMOVE_RECURSE ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg)
        file(MAKE_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg)
        file(COPY ${_csc_SOURCE_PATH} DESTINATION ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg)
        set(SOURCE_COPY_PATH ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/${SOURCE_PATH_SUFFIX})
        vcpkg_execute_required_process(
            COMMAND msbuild ${SOURCE_COPY_PATH}/${_csc_PROJECT_SUBPATH}
                /p:Configuration=${_csc_DEBUG_CONFIGURATION}
                ${_csc_OPTIONS}
                ${_csc_OPTIONS_DEBUG}
            WORKING_DIRECTORY ${SOURCE_COPY_PATH}
            LOGNAME build-${TARGET_TRIPLET}-dbg
        )
        file(GLOB_RECURSE LIBS ${SOURCE_COPY_PATH}/*.lib)
        file(GLOB_RECURSE DLLS ${SOURCE_COPY_PATH}/*.dll)
        if(LIBS)
            file(COPY ${LIBS} DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)
        endif()
        if(DLLS)
            file(COPY ${DLLS} DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin)
        endif()
    endif()

    vcpkg_copy_pdbs()

    if(NOT _csc_SKIP_CLEAN)
        vcpkg_clean_msbuild()
    endif()

    if(DEFINED _csc_INCLUDES_SUBPATH)
        file(COPY ${_csc_SOURCE_PATH}/${_csc_INCLUDES_SUBPATH}/ DESTINATION ${CURRENT_PACKAGES_DIR}/include/)
        file(GLOB ROOT_INCLUDES LIST_DIRECTORIES false ${CURRENT_PACKAGES_DIR}/include/*)
        if(ROOT_INCLUDES)
            if(_csc_REMOVE_ROOT_INCLUDES)
                file(REMOVE ${ROOT_INCLUDES})
            elseif(_csc_ALLOW_ROOT_INCLUDES)
            else()
                message(FATAL_ERROR "Top-level files were found in ${CURRENT_PACKAGES_DIR}/include; this may indicate a problem with the call to `vcpkg_install_msbuild()`.\nTo avoid conflicts with other libraries, it is recommended to not put includes into the root `include/` directory.\nPass either ALLOW_ROOT_INCLUDES or REMOVE_ROOT_INCLUDES to handle these files.\n")
            endif()
        endif()
    endif()

    if(DEFINED _csc_LICENSE_SUBPATH)
        file(INSTALL ${_csc_SOURCE_PATH}/${_csc_LICENSE_SUBPATH} DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
    endif()
endfunction()
