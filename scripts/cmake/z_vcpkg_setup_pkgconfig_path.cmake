#[===[
# z_vcpkg_setup_pkgconfig_path

`z_vcpkg_setup_pkgconfig_path` sets up environment variables to use `pkgconfig`, such as `PKG_CONFIG` and `PKG_CONFIG_PATH`.
The original values are restored with `z_vcpkg_restore_pkgconfig_path`. `BASE_DIRS` indicates the base directories to find `.pc` files; typically `${CURRENT_INSTALLED_DIR}`, or `${CURRENT_INSTALLED_DIR}/debug`.

```cmake
z_vcpkg_setup_pkgconfig_path(BASE_DIRS <"${CURRENT_INSTALLED_DIR}" ...>)
# Build process that may transitively invoke pkgconfig
z_vcpkg_restore_pkgconfig_path()
```

#]===]
function(z_vcpkg_setup_pkgconfig_path)
    cmake_parse_arguments(PARSE_ARGV 0 "arg" "" "" "BASE_DIRS")

    if(NOT DEFINED arg_BASE_DIRS OR "${arg_BASE_DIRS}" STREQUAL "")
        message(FATAL_ERROR "BASE_DIRS is required.")
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

function(z_vcpkg_restore_pkgconfig_path)
    cmake_parse_arguments(PARSE_ARGV 0 "arg" "" "" "")
    if(DEFINED arg_UNPARSED_ARGUMENTS)
        message(FATAL_ERROR "${CMAKE_CURRENT_FUNCTION} was passed extra arguments: ${arg_UNPARSED_ARGUMENTS}")
    endif()

    vcpkg_restore_env_variables(VARS PKG_CONFIG PKG_CONFIG_PATH)
endfunction()
