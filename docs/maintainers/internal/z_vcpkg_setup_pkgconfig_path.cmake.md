# z_vcpkg_setup_pkgconfig_path

Setup the generated pkgconfig file path to PKG_CONFIG_PATH environment variable or restore PKG_CONFIG_PATH environment variable.

```cmake
z_vcpkg_setup_pkgconfig_path(BASE_DIRS <"${CURRENT_INSTALLED_DIR}" ...>)
z_vcpkg_restore_pkgconfig_path()
```

`z_vcpkg_setup_pkgconfig_path` prepends `lib/pkgconfig` and `share/pkgconfig` directories for the given `BASE_DIRS` to the `PKG_CONFIG_PATH` environment variable. It creates or updates a backup of the previous value.
`z_vcpkg_restore_pkgconfig_path` shall be called when leaving the scope which called `z_vcpkg_setup_pkgconfig_path` in order to restore the original value from the backup.
