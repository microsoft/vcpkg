# vcpkg_backup_restore_env_vars

The latest version of this document lives in the [vcpkg repo](https://github.com/Microsoft/vcpkg/blob/master/docs/maintainers/vcpkg_backup_restore_env_vars.md).

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


## Source
[scripts/cmake/vcpkg\_backup\_restore\_env\_vars.cmake](https://github.com/Microsoft/vcpkg/blob/master/scripts/cmake/vcpkg_backup_restore_env_vars.cmake)
