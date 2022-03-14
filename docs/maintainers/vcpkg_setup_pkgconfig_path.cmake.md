# vcpkg_setup_pkgconfig_path

Setup the generated pkgconfig file path to PKG_CONFIG_PATH environment variable or restore PKG_CONFIG_PATH environment variable

```cmake
vcpkg_setup_pkgconfig_path(BASE_DIRS <"${CURRENT_INSTALLED_DIR}" ...>)
```
```cmake
vcpkg_restore_pkgconfig_path()
```

`vcpkg_setup_pkgconfig_path` prepends `lib/pkgconfig` and `share/pkgconfig` directories for the given `BASE_DIRS` to the `PKG_CONFIG_PATH` environment variable. It creates or updates a backup of the previous value.
`vcpkg_restore_pkgconfig_path` shall be called when leaving the scope which called `vcpkg_setup_pkgconfig_path` in order to restore the original value from the backup.
