#[===[.md:
# vcpkg_backup_restore_env_vars

Backup or restore the environment variables

## Usage:
```cmake
vcpkg_backup_env_variables(VARS <ENV_VARS>)
```

```cmake
vcpkg_restore_env_variables(VARS <ENV_VARS>)
```

### ENV_VARS
The target passed to the make build command (`./make <target>`). If not specified, the 'all' target will
be passed.
And the backup variable is `z_vcpkg_env_backup_${ENV_VARS}`.

## Notes:
This command should be preceded by a call to [`vcpkg_backup_env_variables()`](vcpkg_backup_env_variables.md) or
[`vcpkg_restore_env_variables()`](vcpkg_restore_env_variables.md).

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
            debug_message("backup ENV\{${envvar}\} to z_vcpkg_env_backup_${envvar}")
            set("z_vcpkg_env_backup_${envvar}" "$ENV{${envvar}}" PARENT_SCOPE)
        else()
            unset(z_vcpkg_env_backup_${envvar})
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
            debug_message("restore ENV\{${envvar}\} from z_vcpkg_env_backup_${envvar}")
            set(ENV{${envvar}} "${z_vcpkg_env_backup_${envvar}}")
        else()
            unset(ENV{${envvar}})
        endif()
    endforeach()
endfunction()
