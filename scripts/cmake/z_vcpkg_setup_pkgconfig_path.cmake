function(z_vcpkg_setup_pkgconfig_path)
    cmake_parse_arguments(PARSE_ARGV 0 "arg" "" "" "BASE_DIRS")

    if(NOT DEFINED arg_BASE_DIRS OR "${arg_BASE_DIRS}" STREQUAL "")
        message(FATAL_ERROR "BASE_DIRS is required.")
    endif()
    if(DEFINED arg_UNPARSED_ARGUMENTS)
        message(FATAL_ERROR "${CMAKE_CURRENT_FUNCTION} was passed extra arguments: ${arg_UNPARSED_ARGUMENTS}")
    endif()

    foreach(envvar IN ITEMS PKG_CONFIG PKG_CONFIG_PATH)
        if(DEFINED ENV{${envvar}})
            set("z_vcpkg_env_backup_${envvar}" "$ENV{${envvar}}" PARENT_SCOPE)
        else()
            unset("z_vcpkg_env_backup_${envvar}" PARENT_SCOPE)
        endif()
    endforeach()

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

    foreach(envvar IN ITEMS PKG_CONFIG PKG_CONFIG_PATH)
        if(DEFINED z_vcpkg_env_backup_${envvar})
            set("ENV{${envvar}}" "${z_vcpkg_env_backup_${envvar}}")
        else()
            unset("ENV{${envvar}}")
        endif()
    endforeach()
endfunction()
