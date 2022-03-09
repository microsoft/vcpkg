#[===[
# vcpkg_setup_pkgconfig_path

Setup the generated pkgconfig file path to PKG_CONFIG_PATH environment variable or restore PKG_CONFIG_PATH environment variable

```cmake
vcpkg_setup_pkgconfig_path(BASE_DIRS <"${CURRENT_INSTALLED_DIR}" ...>)
```
```cmake
vcpkg_restore_pkgconfig_path()
```

`vcpkg_setup_pkgconfig_path` prepend the default pkgconfig path passed to it to the PKG_CONFIG_PATH environment variable.
`vcpkg_restore_pkgconfig_path` should be called after the configure or build procees end.

#]===]
function(vcpkg_setup_pkgconfig_path)
    cmake_parse_arguments(PARSE_ARGV 0 "arg" "" "" "BASE_DIRS")

    if(NOT DEFINED arg_BASE_DIRS OR "${arg_BASE_DIRS}" STREQUAL "")
        message(FATAL_ERROR "BASE_DIR must be passed in")
    endif()
    if(DEFINED arg_UNPARSED_ARGUMENTS)
        message(FATAL_ERROR "${CMAKE_CURRENT_FUNCTION} was passed extra arguments: ${arg_UNPARSED_ARGUMENTS}")
    endif()

    vcpkg_backup_env_variables(VARS PKGCONFIG_PATH PKG_CONFIG PKG_CONFIG_PATH)

    vcpkg_find_acquire_program(PKGCONFIG)
    get_filename_component(PKGCONFIG_PATH ${PKGCONFIG} DIRECTORY)
    vcpkg_add_to_path("${PKGCONFIG_PATH}")

    if(VCPKG_LIBRARY_LINKAGE STREQUAL "static" AND NOT PKGCONFIG STREQUAL "--static")
        set(PKGCONFIG "${PKGCONFIG} --static") # Is this still required or was the PR changing the pc files accordingly merged?
    endif()
    set(ENV{PKG_CONFIG} "${PKGCONFIG}") # Set via native file?

    foreach(base_dir IN LISTS arg_BASE_DIRS)
        vcpkg_host_path_list(PREPEND ENV{PKG_CONFIG_PATH} "${base_dir}/share/pkgconfig/")
    endforeach()

    foreach(base_dir IN LISTS arg_BASE_DIRS)
        vcpkg_host_path_list(PREPEND ENV{PKG_CONFIG_PATH} "${base_dir}/lib/pkgconfig/")
    endforeach()
endfunction()

function(vcpkg_restore_pkgconfig_path)
    cmake_parse_arguments(PARSE_ARGV 0 "arg" "" "" "")
    if(DEFINED arg_UNPARSED_ARGUMENTS)
        message(FATAL_ERROR "${CMAKE_CURRENT_FUNCTION} was passed extra arguments: ${arg_UNPARSED_ARGUMENTS}")
    endif()

    vcpkg_restore_env_variables(VARS PKGCONFIG_PATH PKG_CONFIG PKG_CONFIG_PATH)
endfunction()
