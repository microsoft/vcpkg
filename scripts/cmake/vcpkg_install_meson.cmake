## # vcpkg_install_meson
##
## Builds a meson project previously configured with `vcpkg_configure_meson()`.
##
## ## Usage
## ```cmake
## vcpkg_install_meson()
## ```
##
## ## Examples
##
## * [fribidi](https://github.com/Microsoft/vcpkg/blob/master/ports/fribidi/portfile.cmake)
## * [libepoxy](https://github.com/Microsoft/vcpkg/blob/master/ports/libepoxy/portfile.cmake)
function(vcpkg_install_meson)
    vcpkg_find_acquire_program(NINJA)
    unset(ENV{DESTDIR}) # installation directory was already specified with '--prefix' option

    message(STATUS "Package ${TARGET_TRIPLET}-rel")
    vcpkg_execute_required_process(
        COMMAND ${NINJA} install -v
        WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel
        LOGNAME package-${TARGET_TRIPLET}-rel
    )

    message(STATUS "Package ${TARGET_TRIPLET}-dbg")
    vcpkg_execute_required_process(
        COMMAND ${NINJA} install -v
        WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg
        LOGNAME package-${TARGET_TRIPLET}-dbg
    )
endfunction()
