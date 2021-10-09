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

## Notes:
This command should be preceded by a call to [`vcpkg_configure_make()`](vcpkg_configure_make.md).
You can use the alias [`vcpkg_install_make()`](vcpkg_install_make.md) function if your makefile supports the
"install" target

#]===]

macro(z_vcpkg_backup_env_variable envvar)
    if(DEFINED ENV{${envvar}})
        debug_message("backup ENV\{${envvar}\} to ${envvar}_backup")
        set("z_vcpkg_env_backup_${envvar}" "$ENV{${envvar}}" PARENT_SCOPE)
    else()
        unset(z_vcpkg_env_backup_${envvar})
    endif()
endmacro()

macro(z_vcpkg_restore_env_variable envvar)
    if(DEFINED ${envvar}_backup)
        debug_message("restore ENV\{${envvar}\} from z_vcpkg_env_backup_${envvar}")
        set(ENV{${envvar}} "${z_vcpkg_env_backup_${envvar}}")
    else()
        unset(ENV{${envvar}})
    endif()
endmacro()

function(vcpkg_backup_env_variables)
    cmake_parse_arguments(PARSE_ARGV 0 arg "" "" "VARS")
    if(NOT DEFINED arg_VARS)
        message(FATAL_ERROR "VARS must be defined.")
    endif()
    if(DEFINED arg_UNPARSED_ARGUMENTS)
        message(FATAL_ERROR "${CMAKE_CURRENT_FUNCTION} was passed extra arguments: ${arg_UNPARSED_ARGUMENTS}")
    endif()

    foreach(envvar IN ITEMS ${arg_VARS})
        z_vcpkg_backup_env_variable("${envvar}")
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

    foreach(envvar IN ITEMS ${arg_VARS})
        z_vcpkg_restore_env_variable("${envvar}")
    endforeach()
endfunction()
