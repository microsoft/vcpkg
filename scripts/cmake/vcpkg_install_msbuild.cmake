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

* [xalan-c](https://github.com/Microsoft/vcpkg/blob/master/ports/xalan-c/portfile.cmake)
* [libimobiledevice](https://github.com/Microsoft/vcpkg/blob/master/ports/libimobiledevice/portfile.cmake)
#]===]

include(vcpkg_clean_msbuild)

function(vcpkg_install_msbuild)
    # parse parameters such that semicolons in options arguments to COMMAND don't get erased
    cmake_parse_arguments(
        PARSE_ARGV 0
        _csc
        "USE_VCPKG_INTEGRATION;ALLOW_ROOT_INCLUDES;REMOVE_ROOT_INCLUDES;SKIP_CLEAN"
        "SOURCE_PATH;PROJECT_SUBPATH;INCLUDES_SUBPATH;LICENSE_SUBPATH;RELEASE_CONFIGURATION;DEBUG_CONFIGURATION;PLATFORM;PLATFORM_TOOLSET;TARGET_PLATFORM_VERSION;TARGET"
        "OPTIONS;OPTIONS_RELEASE;OPTIONS_DEBUG"
    )

    function(fast_copy SRC DEST)
        if(CMAKE_HOST_WIN32)
            get_filename_component(F ${SRC} NAME)
            file(TO_NATIVE_PATH "${SRC}" SRC)
            file(TO_NATIVE_PATH "${DEST}/${F}" DEST)
            file(MAKE_DIRECTORY "${DEST}")
            execute_process(
                COMMAND xcopy /E /Q /B /J "${SRC}" "${DEST}"
                RESULT_VARIABLE N
                OUTPUT_VARIABLE OUT
                ERROR_VARIABLE OUT
            )
            if(NOT N EQUAL 0)
                message(FATAL_ERROR "xcopy /E /Q /B /J \"${SRC}\" \"${DEST}\" failed:\n${OUT}")
            endif()
        else()
            file(COPY "${SRC}" DESTINATION "${DEST}")
        endif()
    endfunction()

    set(BUILD_MSBUILD_OPTIONS
        _PASS_VCPKG_VARS
        OPTIONS ${_csc_OPTIONS}
        OPTIONS_RELEASE ${_csc_OPTIONS_RELEASE}
        OPTIONS_DEBUG ${_csc_OPTIONS_DEBUG}
    )
    if(DEFINED _csc_TARGET)
        list(APPEND BUILD_MSBUILD_OPTIONS TARGET ${_csc_TARGET})
    endif()
    if(DEFINED _csc_TARGET_PLATFORM_VERSION)
        list(APPEND BUILD_MSBUILD_OPTIONS TARGET_PLATFORM_VERSION ${_csc_TARGET_PLATFORM_VERSION})
    endif()
    if(DEFINED _csc_PLATFORM_TOOLSET)
        list(APPEND BUILD_MSBUILD_OPTIONS PLATFORM_TOOLSET ${_csc_PLATFORM_TOOLSET})
    endif()
    if(NOT DEFINED _csc_PLATFORM)
        if(VCPKG_TARGET_ARCHITECTURE STREQUAL x64)
            set(_csc_PLATFORM x64)
        elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL x86)
            set(_csc_PLATFORM Win32)
        elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL ARM)
            set(_csc_PLATFORM ARM)
        elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL arm64)
            set(_csc_PLATFORM arm64)
        else()
            message(FATAL_ERROR "Unsupported target architecture")
        endif()
    endif()
    list(APPEND BUILD_MSBUILD_OPTIONS PLATFORM ${_csc_PLATFORM})
    if(DEFINED _csc_USE_VCPKG_INTEGRATION)
        list(APPEND BUILD_MSBUILD_OPTIONS USE_VCPKG_INTEGRATION DISABLE_APPLOCAL_DEPS)
    endif()
    if(DEFINED _csc_DEBUG_CONFIGURATION)
        list(APPEND BUILD_MSBUILD_OPTIONS DEBUG_CONFIGURATION ${_csc_DEBUG_CONFIGURATION})
    endif()
    if(DEFINED _csc_RELEASE_CONFIGURATION)
        list(APPEND BUILD_MSBUILD_OPTIONS RELEASE_CONFIGURATION ${_csc_RELEASE_CONFIGURATION})
    endif()
    get_filename_component(SOURCE_PATH_SUFFIX "${_csc_SOURCE_PATH}" NAME)
    set(_VCPKG_BUILD_TYPE "${VCPKG_BUILD_TYPE}")
    if(_VCPKG_BUILD_TYPE STREQUAL "" OR _VCPKG_BUILD_TYPE STREQUAL "release")
        message(STATUS "Copying sources for Release")
        file(REMOVE_RECURSE ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel)
        file(MAKE_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel)
        fast_copy("${_csc_SOURCE_PATH}" "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel")
        set(SOURCE_COPY_PATH ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/${SOURCE_PATH_SUFFIX})

        set(VCPKG_BUILD_TYPE release)
        vcpkg_build_msbuild(
            PROJECT_PATH ${SOURCE_COPY_PATH}/${_csc_PROJECT_SUBPATH}
            ${BUILD_MSBUILD_OPTIONS}
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

    if(_VCPKG_BUILD_TYPE STREQUAL "" OR _VCPKG_BUILD_TYPE STREQUAL "debug")
        message(STATUS "Copying sources for Debug")
        file(REMOVE_RECURSE ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg)
        file(MAKE_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg)
        fast_copy("${_csc_SOURCE_PATH}" "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg")
        set(SOURCE_COPY_PATH ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/${SOURCE_PATH_SUFFIX})

        set(VCPKG_BUILD_TYPE debug)
        vcpkg_build_msbuild(
            PROJECT_PATH ${SOURCE_COPY_PATH}/${_csc_PROJECT_SUBPATH}
            ${BUILD_MSBUILD_OPTIONS}
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
