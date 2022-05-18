#[===[.md:
# vcpkg_backup_restore_env_vars

Backup or restore the environment variables

## Usage:
```cmake
vcpkg_backup_env_variables(VARS [<environment-variable>...])
vcpkg_restore_env_variables(VARS [<environment-variable>...])
```

### VARS
The variables to back up or restore.
These are placed in the parent scope, so you must backup and restore
from the same scope.

## Notes
One must always call `vcpkg_backup_env_variables` before
`vcpkg_restore_env_variables`; however, `vcpkg_restore_env_variables`
does not change the back up variables, and so you may call `restore`
multiple times for one `backup`.

#]===]

function(vcpkg_backup_env_variables)
    cmake_parse_arguments(PARSE_ARGV 0 arg "" "" "VARS")
    if(NOT DEFINED arg_VARS)
        message(FATAL_ERROR "VARS must be defined.")
    endif()
    if(DEFINED arg_UNPARSED_ARGUMENTS)
        message(FATAL_ERROR "${CMAKE_CURRENT_FUNCTION} was passed extra arguments: ${arg_UNPARSED_ARGUMENTS}")
    endif()

    foreach(envvar IN LISTS arg_VARS)
        if(DEFINED ENV{${envvar}})
            set("z_vcpkg_env_backup_${envvar}" "$ENV{${envvar}}" PARENT_SCOPE)
        else()
            unset("z_vcpkg_env_backup_${envvar}" PARENT_SCOPE)
        endif()
    endforeach()
endfunction()

function(vcpkg_restore_env_variables)
    cmake_parse_arguments(PARSE_ARGV 0 arg "" "" "VARS")
    if(NOT DEFINED arg_VARS)
        message(FATAL_ERROR "VARS must be defined.")
    endif()
    if(DEFINED arg_UNPARSED_ARGUMENTS)
        message(FATAL_ERROR "${CMAKE_CURRENT_FUNCTION} was passed extra arguments: ${arg_UNPARSED_ARGUMENTS}")
    endif()

    foreach(envvar IN LISTS arg_VARS)
        if(DEFINED z_vcpkg_env_backup_${envvar})
            set("ENV{${envvar}}" "${z_vcpkg_env_backup_${envvar}}")
        else()
            unset("ENV{${envvar}}")
        endif()
    endforeach()
endfunction()
