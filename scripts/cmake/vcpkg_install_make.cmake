## # vcpkg_install_make
##
## Build and install a make project.
##
## ## Usage:
## ```cmake
## vcpkg_install_make(
##     [MAKE_OPTIONS <-DUSE_THIS_IN_ALL_BUILDS=1>...]
##     [MAKE_OPTIONS_RELEASE <-DOPTIMIZE=1>...]
##     [MAKE_OPTIONS_DEBUG <-DDEBUGGABLE=1>...]
##     [MAKE_INSTALL_OPTIONS <-DUSE_THIS_IN_ALL_BUILDS=1>...]
##     [MAKE_INSTALL_OPTIONS_RELEASE <-DOPTIMIZE=1>...]
##     [MAKE_INSTALL_OPTIONS_DEBUG <-DDEBUGGABLE=1>...])
## ```
##
## ## Parameters:
## ### MAKE_OPTIONS
## Additional options passed to make during the generation.
##
## ### MAKE_OPTIONS_RELEASE
## Additional options passed to make during the Release generation. These are in addition to `MAKE_OPTIONS`.
##
## ### MAKE_OPTIONS_DEBUG
## Additional options passed to make during the Debug generation. These are in addition to `MAKE_OPTIONS`.
##
## ### MAKE_INSTALL_OPTIONS
## Additional options passed to make during the installation.
##
## ### MAKE_INSTALL_OPTIONS_RELEASE
## Additional options passed to make during the Release installation. These are in addition to `MAKE_INSTALL_OPTIONS`.
##
## ### MAKE_INSTALL_OPTIONS_DEBUG
## Additional options passed to make during the Debug installation. These are in addition to `MAKE_INSTALL_OPTIONS`.
##
## ## Notes:
## This command transparently forwards to [`vcpkg_build_make()`](vcpkg_build_make.md), adding `ENABLE_INSTALL`
##
## ## Examples
##
## * [x264](https://github.com/Microsoft/vcpkg/blob/master/ports/x264/portfile.cmake)
## * [tcl](https://github.com/Microsoft/vcpkg/blob/master/ports/tcl/portfile.cmake)
## * [freexl](https://github.com/Microsoft/vcpkg/blob/master/ports/freexl/portfile.cmake)
## * [libosip2](https://github.com/Microsoft/vcpkg/blob/master/ports/libosip2/portfile.cmake)

function(vcpkg_install_make)
    cmake_parse_arguments(_ic
        ""
        ""
        "MAKE_OPTIONS;MAKE_OPTIONS_DEBUG;MAKE_OPTIONS_RELEASE;MAKE_INSTALL_OPTIONS;MAKE_INSTALL_OPTIONS_DEBUG;MAKE_INSTALL_OPTIONS_RELEASE"
        ${ARGN}
    )

    vcpkg_build_make(LOGFILE_ROOT ENABLE_INSTALL
        MAKE_OPTIONS ${_ic_MAKE_OPTIONS}
        MAKE_OPTIONS_RELEASE ${_ic_MAKE_OPTIONS_RELEASE}
        MAKE_OPTIONS_DEBUG ${_ic_MAKE_OPTIONS_DEBUG}
        MAKE_INSTALL_OPTIONS ${_ic_MAKE_INSTALL_OPTIONS}
        MAKE_INSTALL_OPTIONS_RELEASE ${_ic_MAKE_INSTALL_OPTIONS_RELEASE}
        MAKE_INSTALL_OPTIONS_DEBUG ${_ic_MAKE_INSTALL_OPTIONS_DEBUG}
    )
endfunction()
