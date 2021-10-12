# vcpkg_backup_restore_env_vars

The latest version of this document lives in the [vcpkg repo](https://github.com/Microsoft/vcpkg/blob/master/docs/maintainers/vcpkg_backup_restore_env_vars.md).

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


## Source
[scripts/cmake/vcpkg\_backup\_restore\_env\_vars.cmake](https://github.com/Microsoft/vcpkg/blob/master/scripts/cmake/vcpkg_backup_restore_env_vars.cmake)
