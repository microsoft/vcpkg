# licensecc vcpkg port

This port provides vcpkg package management support for the [licensecc](https://github.com/open-license-manager/licensecc) library.

## About licensecc

LicenseCC is a cross-platform C++ license management library with hardware fingerprinting and trial support.

## Usage

```cmake
find_package(licensecc CONFIG REQUIRED)
target_link_libraries(main PRIVATE licensecc::licensecc_static)
```

## License

- The licensecc library is licensed under BSD-3-Clause
- This vcpkg port is maintained by community contributors and is not affiliated with the original project

## Contributors

- Initial port created and maintained by [your GitHub username]
- Original library developed by the open-license-manager team
