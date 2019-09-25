## # vcpkg_install_make
##
## Build and install a make project.
##
## ## Usage:
## ```cmake
## vcpkg_install_make(...)
## ```
##
## ## Parameters:
## See [`vcpkg_build_make()`](vcpkg_build_make.md).
##
## ## Notes:
## This command transparently forwards to [`vcpkg_build_make()`](vcpkg_build_make.md), adding `ENABLE_INSTALL`

function(vcpkg_install_make)
    vcpkg_build_make(LOGFILE_ROOT ENABLE_INSTALL)
endfunction()
