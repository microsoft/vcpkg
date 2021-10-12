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
