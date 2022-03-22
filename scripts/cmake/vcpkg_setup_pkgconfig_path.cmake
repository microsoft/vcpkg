#[===[
# vcpkg_setup_pkgconfig_path

Setup the generated pkgconfig file path to PKG_CONFIG_PATH environment variable or restore PKG_CONFIG_PATH environment variable.

```cmake
vcpkg_setup_pkgconfig_path(BASE_DIRS <"${CURRENT_INSTALLED_DIR}" ...>)
```
```cmake
vcpkg_restore_pkgconfig_path()
```

`vcpkg_setup_pkgconfig_path` prepends `lib/pkgconfig` and `share/pkgconfig` directories for the given `BASE_DIRS` to the `PKG_CONFIG_PATH` environment variable. It creates or updates a backup of the previous value.
`vcpkg_restore_pkgconfig_path` shall be called when leaving the scope which called `vcpkg_setup_pkgconfig_path` in order to restore the original value from the backup.

#]===]
function(vcpkg_setup_pkgconfig_path)
    cmake_parse_arguments(PARSE_ARGV 0 "arg" "" "" "BASE_DIRS")

    if(NOT DEFINED arg_BASE_DIRS OR "${arg_BASE_DIRS}" STREQUAL "")
        message(FATAL_ERROR "BASE_DIR must be passed in")
    endif()
    if(DEFINED arg_UNPARSED_ARGUMENTS)
        message(FATAL_ERROR "${CMAKE_CURRENT_FUNCTION} was passed extra arguments: ${arg_UNPARSED_ARGUMENTS}")
    endif()

    vcpkg_backup_env_variables(VARS PKG_CONFIG PKG_CONFIG_PATH)

    vcpkg_find_acquire_program(PKGCONFIG)
    get_filename_component(pkgconfig_path "${PKGCONFIG}" DIRECTORY)
    vcpkg_add_to_path("${pkgconfig_path}")

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

    vcpkg_restore_env_variables(VARS PKG_CONFIG PKG_CONFIG_PATH)
endfunction()
