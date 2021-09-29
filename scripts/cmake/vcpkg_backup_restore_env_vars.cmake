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
        set(${envvar}_backup "$ENV{${envvar}}" PARENT_SCOPE)
    else()
        unset(${envvar}_backup)
    endif()
endmacro()

macro(z_vcpkg_restore_env_variable envvar)
    if(${envvar}_backup)
        debug_message("restore ENV\{${envvar}\} from ${${envvar}_backup}")
        set(ENV{${envvar}} "${${envvar}_backup}")
    else()
        unset(ENV{${envvar}})
    endif()
endmacro()

function(vcpkg_backup_env_variables)
    cmake_parse_arguments(PARSE_ARGV 0 arg "" "" "VARS")
    foreach(envvar IN ITEMS ${arg_VARS})
        z_vcpkg_backup_env_variable(${envvar})
    endforeach()
endfunction()

function(vcpkg_restore_env_variables)
    cmake_parse_arguments(PARSE_ARGV 0 arg "" "" "VARS")
    foreach(envvar IN ITEMS ${arg_VARS})
        z_vcpkg_restore_env_variable(${envvar})
    endforeach()
endfunction()