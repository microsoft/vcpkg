#[===[.md:
# vcpkg_build_nmake

Build a msvc makefile project.

## Usage:
```cmake
vcpkg_build_nmake(
    SOURCE_PATH <${SOURCE_PATH}>
    [NO_DEBUG]
    [ENABLE_INSTALL]
    [TARGET <all>]
    [PROJECT_SUBPATH <${SUBPATH}>]
    [PROJECT_NAME <${MAKEFILE_NAME}>]
    [PRERUN_SHELL <${SHELL_PATH}>]
    [PRERUN_SHELL_DEBUG <${SHELL_PATH}>]
    [PRERUN_SHELL_RELEASE <${SHELL_PATH}>]
    [OPTIONS <-DUSE_THIS_IN_ALL_BUILDS=1>...]
    [OPTIONS_RELEASE <-DOPTIMIZE=1>...]
    [OPTIONS_DEBUG <-DDEBUGGABLE=1>...]
    [TARGET <target>])
```

## Parameters
### SOURCE_PATH
Specifies the directory containing the source files.
By convention, this is usually set in the portfile as the variable `SOURCE_PATH`.

### PROJECT_SUBPATH
Specifies the sub directory containing the `makefile.vc`/`makefile.mak`/`makefile.msvc` or other msvc makefile.

### PROJECT_NAME
Specifies the name of msvc makefile name.
Default is `makefile.vc`

### NO_DEBUG
This port doesn't support debug mode.

### ENABLE_INSTALL
Install binaries after build.

### PRERUN_SHELL
Script that needs to be called before build

### PRERUN_SHELL_DEBUG
Script that needs to be called before debug build

### PRERUN_SHELL_RELEASE
Script that needs to be called before release build

### OPTIONS
Additional options passed to generate during the generation.

### OPTIONS_RELEASE
Additional options passed to generate during the Release generation. These are in addition to `OPTIONS`.

### OPTIONS_DEBUG
Additional options passed to generate during the Debug generation. These are in addition to `OPTIONS`.

### TARGET
The target passed to the nmake build command (`nmake/nmake install`). If not specified, no target will
be passed.

### ADD_BIN_TO_PATH
Adds the appropriate Release and Debug `bin\` directories to the path during the build such that executables can run against the in-tree DLLs.

## Notes:
You can use the alias [`vcpkg_install_nmake()`](vcpkg_install_nmake.md) function if your makefile supports the
"install" target

## Examples

* [tcl](https://github.com/Microsoft/vcpkg/blob/master/ports/tcl/portfile.cmake)
* [freexl](https://github.com/Microsoft/vcpkg/blob/master/ports/freexl/portfile.cmake)
#]===]

function(vcpkg_build_nmake)
    # parse parameters such that semicolons in options arguments to COMMAND don't get erased
    cmake_parse_arguments(PARSE_ARGV 0 _bn
        "ADD_BIN_TO_PATH;ENABLE_INSTALL;NO_DEBUG"
        "SOURCE_PATH;PROJECT_SUBPATH;PROJECT_NAME;LOGFILE_ROOT"
        "OPTIONS;OPTIONS_RELEASE;OPTIONS_DEBUG;PRERUN_SHELL;PRERUN_SHELL_DEBUG;PRERUN_SHELL_RELEASE;TARGET"
    )
    
    if (NOT CMAKE_HOST_WIN32)
        message(FATAL_ERROR "vcpkg_build_nmake only support windows.")
    endif()
    
    if (_bn_OPTIONS_DEBUG STREQUAL _bn_OPTIONS_RELEASE)
        message(FATAL_ERROR "Detected debug configuration is equal to release configuration, please use NO_DEBUG for vcpkg_build_nmake/vcpkg_install_nmake")
    endif()

    if(NOT _bn_LOGFILE_ROOT)
        set(_bn_LOGFILE_ROOT "build")
    endif()
    
    if (NOT _bn_PROJECT_NAME)
        set(MAKEFILE_NAME makefile.vc)
    else()
        set(MAKEFILE_NAME ${_bn_PROJECT_NAME})
    endif()
    
    set(MAKE )
    set(MAKE_OPTS_BASE )
    
    find_program(NMAKE nmake REQUIRED)
    get_filename_component(NMAKE_EXE_PATH ${NMAKE} DIRECTORY)
    # Load toolchains
    if(NOT VCPKG_CHAINLOAD_TOOLCHAIN_FILE)
        set(VCPKG_CHAINLOAD_TOOLCHAIN_FILE "${SCRIPTS}/toolchains/windows.cmake")
    endif()
    include("${VCPKG_CHAINLOAD_TOOLCHAIN_FILE}")
    # Set needed env
    set(ENV{PATH} "$ENV{PATH};${NMAKE_EXE_PATH}")
    set(ENV{INCLUDE} "${CURRENT_INSTALLED_DIR}/include;$ENV{INCLUDE}")
    # Set make command and install command
    set(MAKE ${NMAKE} /NOLOGO /G /U)
    set(MAKE_OPTS_BASE -f ${MAKEFILE_NAME})
    if (_bn_ENABLE_INSTALL)
        set(INSTALL_COMMAND install)
    endif()
    if (_bn_TARGET)
        set(MAKE_OPTS_BASE ${MAKE_OPTS_BASE} ${_bn_TARGET} ${INSTALL_COMMAND})
    else()
        set(MAKE_OPTS_BASE ${MAKE_OPTS_BASE} all ${INSTALL_COMMAND})
    endif()
    # Add subpath to work directory
    if (_bn_PROJECT_SUBPATH)
        set(_bn_PROJECT_SUBPATH /${_bn_PROJECT_SUBPATH})
    else()
        set(_bn_PROJECT_SUBPATH )
    endif()
    
    foreach(BUILDTYPE "debug" "release")
        if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL BUILDTYPE)
            if(BUILDTYPE STREQUAL "debug")
                # Skip debug generate
                if (_bn_NO_DEBUG)
                    continue()
                endif()
                # Generate obj dir suffix
                set(SHORT_BUILDTYPE "-dbg")
                set(CONFIG "Debug")
                # Add install command and arguments
                set(MAKE_OPTS ${MAKE_OPTS_BASE})
                if (_bn_ENABLE_INSTALL)
                    set(INSTALL_OPTS INSTALLDIR=${CURRENT_PACKAGES_DIR}/debug)
                    set(MAKE_OPTS ${MAKE_OPTS} ${INSTALL_OPTS})
                endif()
                set(MAKE_OPTS ${MAKE_OPTS} ${_bn_OPTIONS} ${_bn_OPTIONS_DEBUG})
                
                unset(ENV{CL})
                set(TMP_CL_FLAGS "${CMAKE_CXX_FLAGS} ${CMAKE_CXX_FLAGS_DEBUG}")
                string(REPLACE "/" "-" TMP_CL_FLAGS "${TMP_CL_FLAGS}")
                set(ENV{CL} "$ENV{CL} ${TMP_CL_FLAGS}")
            else()
                # In NO_DEBUG mode, we only use ${TARGET_TRIPLET} directory.
                if (_bn_NO_DEBUG)
                    set(SHORT_BUILDTYPE "")
                else()
                    set(SHORT_BUILDTYPE "-rel")
                endif()
                set(CONFIG "Release")
                # Add install command and arguments
                set(MAKE_OPTS ${MAKE_OPTS_BASE})
                if (_bn_ENABLE_INSTALL)
                    set(INSTALL_OPTS INSTALLDIR=${CURRENT_PACKAGES_DIR})
                    set(MAKE_OPTS ${MAKE_OPTS} ${INSTALL_OPTS})
                endif()
                set(MAKE_OPTS ${MAKE_OPTS} ${_bn_OPTIONS} ${_bn_OPTIONS_RELEASE})
                
                unset(ENV{CL})
                set(TMP_CL_FLAGS "${CMAKE_CXX_FLAGS} ${CMAKE_CXX_FLAGS_RELEASE}")
                string(REPLACE "/" "-" TMP_CL_FLAGS "${TMP_CL_FLAGS}")
                set(ENV{CL} "$ENV{CL} ${TMP_CL_FLAGS}")
            endif()
            
            set(CURRENT_TRIPLET_NAME ${TARGET_TRIPLET}${SHORT_BUILDTYPE})
            set(OBJ_DIR ${CURRENT_BUILDTREES_DIR}/${CURRENT_TRIPLET_NAME})
            
            file(REMOVE_RECURSE ${OBJ_DIR})
            file(MAKE_DIRECTORY ${OBJ_DIR})
            file(GLOB_RECURSE SOURCE_FILES ${_bn_SOURCE_PATH}/*)
            foreach(ONE_SOUCRCE_FILE ${SOURCE_FILES})
                get_filename_component(DST_DIR ${ONE_SOUCRCE_FILE} PATH)
                string(REPLACE "${_bn_SOURCE_PATH}" "${OBJ_DIR}" DST_DIR "${DST_DIR}")
                file(COPY ${ONE_SOUCRCE_FILE} DESTINATION ${DST_DIR})
            endforeach()
            
            if (_bn_PRERUN_SHELL)
                message(STATUS "Prerunning ${CURRENT_TRIPLET_NAME}")
                vcpkg_execute_required_process(
                    COMMAND ${_bn_PRERUN_SHELL}
                    WORKING_DIRECTORY ${OBJ_DIR}${_bn_PROJECT_SUBPATH}
                    LOGNAME "$prerun-${CURRENT_TRIPLET_NAME}"
                )
            endif()
            if (BUILDTYPE STREQUAL "debug" AND _bn_PRERUN_SHELL_DEBUG)
                message(STATUS "Prerunning ${CURRENT_TRIPLET_NAME}")
                vcpkg_execute_required_process(
                    COMMAND ${_bn_PRERUN_SHELL_DEBUG}
                    WORKING_DIRECTORY ${OBJ_DIR}${_bn_PROJECT_SUBPATH}
                    LOGNAME "prerun-${CURRENT_TRIPLET_NAME}-dbg"
                )
            endif()
            if (BUILDTYPE STREQUAL "release" AND _bn_PRERUN_SHELL_RELEASE)
                message(STATUS "Prerunning ${CURRENT_TRIPLET_NAME}")
                vcpkg_execute_required_process(
                    COMMAND ${_bn_PRERUN_SHELL_RELEASE}
                    WORKING_DIRECTORY ${OBJ_DIR}${_bn_PROJECT_SUBPATH}
                    LOGNAME "prerun-${CURRENT_TRIPLET_NAME}-rel"
                )
            endif()

            if (NOT _bn_ENABLE_INSTALL)
                message(STATUS "Building ${CURRENT_TRIPLET_NAME}")
            else()
                message(STATUS "Building and installing ${CURRENT_TRIPLET_NAME}")
            endif()

            vcpkg_execute_build_process(
                COMMAND ${MAKE} ${MAKE_OPTS}
                WORKING_DIRECTORY ${OBJ_DIR}${_bn_PROJECT_SUBPATH}
                LOGNAME "${_bn_LOGFILE_ROOT}-${CURRENT_TRIPLET_NAME}"
            )

            if(_bn_ADD_BIN_TO_PATH)
                set(ENV{PATH} "${_BACKUP_ENV_PATH}")
            endif()
        endif()
    endforeach()
endfunction()
