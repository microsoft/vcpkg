# vcpkg_setup_pkgconfig_path

Setup the generated pkgconfig file path to PKG_CONFIG_PATH environment variable or restore PKG_CONFIG_PATH environment variable

```cmake
vcpkg_setup_pkgconfig_path(BASE_DIRS <"${CURRENT_INSTALLED_DIR}" ...>)
```
```cmake
vcpkg_restore_pkgconfig_path()
```

`vcpkg_setup_pkgconfig_path` prepend the default pkgconfig path passed to it to the PKG_CONFIG_PATH environment variable.
`vcpkg_restore_pkgconfig_path` should be called after the configure or build procees end.
