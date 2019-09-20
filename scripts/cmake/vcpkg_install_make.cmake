## # vcpkg_install_make
##
## Build and install a cmake project.
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
## This command transparently forwards to [`vcpkg_build_make()`](vcpkg_build_make.md), adding a `TARGET install`

function(vcpkg_install_make)
    vcpkg_build_make(LOGFILE_ROOT ENABLE_INSTALL)
endfunction()
