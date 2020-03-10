## # vcpkg_install_nmake
##
## Build and install a msvc makefile project.
##
## ## Usage:
## ```cmake
## vcpkg_install_nmake(
##     SOURCE_PATH <${SOURCE_PATH}>
##     [NO_DEBUG]
##     PROJECT_SUBPATH <${SUBPATH}>
##     PROJECT_NAME <${MAKEFILE_NAME}>
##     [PRERUN_SHELL <${SHELL_PATH}>]
##     [PRERUN_SHELL_DEBUG <${SHELL_PATH}>]
##     [PRERUN_SHELL_RELEASE <${SHELL_PATH}>]
##     [OPTIONS <-DUSE_THIS_IN_ALL_BUILDS=1>...]
##     [OPTIONS_RELEASE <-DOPTIMIZE=1>...]
##     [OPTIONS_DEBUG <-DDEBUGGABLE=1>...]
## ```
##
## ## Parameters
## ### SOURCE_PATH
## Specifies the directory containing the source files.
## By convention, this is usually set in the portfile as the variable `SOURCE_PATH`.
##
## ### PROJECT_SUBPATH
## Specifies the sub directory containing the `makefile.vc`/`makefile.mak`/`makefile.msvc` or other msvc makefile.
##
## ### PROJECT_NAME
## Specifies the name of msvc makefile name.
## Default is makefile.vc
##
## ### NO_DEBUG
## This port doesn't support debug mode.
##
## ### PRERUN_SHELL
## Script that needs to be called before build
##
## ### PRERUN_SHELL_DEBUG
## Script that needs to be called before debug build
##
## ### PRERUN_SHELL_RELEASE
## Script that needs to be called before release build
##
## ### OPTIONS
## Additional options passed to generate during the generation.
##
## ### OPTIONS_RELEASE
## Additional options passed to generate during the Release generation. These are in addition to `OPTIONS`.
##
## ### OPTIONS_DEBUG
## Additional options passed to generate during the Debug generation. These are in addition to `OPTIONS`.
##
## ## Parameters:
## See [`vcpkg_build_nmake()`](vcpkg_build_nmake.md).
##
## ## Notes:
## This command transparently forwards to [`vcpkg_build_nmake()`](vcpkg_build_nmake.md), adding `ENABLE_INSTALL`
##
## ## Examples
##
## * [tcl](https://github.com/Microsoft/vcpkg/blob/master/ports/tcl/portfile.cmake)
## * [freexl](https://github.com/Microsoft/vcpkg/blob/master/ports/freexl/portfile.cmake)

function(vcpkg_install_nmake)
    cmake_parse_arguments(_in
        "NO_DEBUG"
        "SOURCE_PATH;PROJECT_SUBPATH;PROJECT_NAME"
        "OPTIONS;OPTIONS_RELEASE;OPTIONS_DEBUG;PRERUN_SHELL;PRERUN_SHELL_DEBUG;PRERUN_SHELL_RELEASE"
        ${ARGN}
    )
    
    if (NOT CMAKE_HOST_WIN32)
        message(FATAL_ERROR "vcpkg_install_nmake only support windows.")
    endif()
    
    if (_in_NO_DEBUG)
        set(NO_DEBUG NO_DEBUG)
    endif()
    
    vcpkg_build_nmake(LOGFILE_ROOT ENABLE_INSTALL
        ${NO_DEBUG}
        SOURCE_PATH ${_in_SOURCE_PATH} PROJECT_SUBPATH ${_in_PROJECT_SUBPATH} PROJECT_NAME ${_in_PROJECT_NAME}
        PRERUN_SHELL ${_in_PRERUN_SHELL} PRERUN_SHELL_DEBUG ${_in_PRERUN_SHELL_DEBUG} PRERUN_SHELL_RELEASE ${_in_PRERUN_SHELL_RELEASE}
        OPTIONS ${_in_OPTIONS} OPTIONS_RELEASE ${_in_OPTIONS_RELEASE} OPTIONS_DEBUG ${_in_OPTIONS_DEBUG}
    )
endfunction()
