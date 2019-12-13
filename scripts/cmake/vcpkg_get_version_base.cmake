## # vcpkg_get_version_base
##
## This is a convenience function to get the base version from the supplied
## Version.
## The base version refers to a version without the modification
## number.

## Given a version string in the format described in the CONTROL files docs,
## this function attempts to get the base part of the string.
##
## This function should not be used when the version is specified as a date or
## if the version contains dashes as part of the base version.
##
## ## Usage:
## ```cmake
## vcpkg_get_version_base(VERSION BASE_VERSION)
## ```
##
## ## Examples:
## ```cmake
## vcpkg_get_port_version_base( "1.2.3"   BASE_VER ) # Results in 1.2.3
## vcpkg_get_port_version_base( "1.2.3-2" BASE_VER ) # Results in 1.2.3
## vcpkg_get_port_version_base( "1_2_3-2" BASE_VER ) # Results in 1_2_3
## ```
##
## ## Parameters:
##
## ### VERSION
## The version string.
##
## ### BASE_VERSION
## Name of the variable that will contain the resulting version string.
##
function(vcpkg_get_version_base ver_in ret)

    set(${ret} "")

    if ("${ver_in}" STREQUAL "")
      message(FATAL_ERROR "ver_in can not be empty")
    endif()

    string(REGEX REPLACE "([^-]+)(-.+)" "\\1" ret_temp "${ver_in}")

    if ("${ret_temp}" STREQUAL "")
        set(ret_temp ${ver_in})
    endif()

    set(${ret} "${ret_temp}" PARENT_SCOPE)

endfunction()