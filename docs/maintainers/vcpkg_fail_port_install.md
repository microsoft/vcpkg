# vcpkg_fail_port_install

The latest version of this document lives in the [vcpkg repo](https://github.com/Microsoft/vcpkg/blob/master/docs/maintainers/vcpkg_fail_port_install.md).

This function is deprecated, please use `supports` field in manifest file or directly add `${PORT}:${FAILED_TRIPLET}=fail` to _scripts/ci.baseline.txt_ instead.

## Source
[scripts/cmake/vcpkg\_fail\_port\_install.cmake](https://github.com/Microsoft/vcpkg/blob/master/scripts/cmake/vcpkg_fail_port_install.cmake)
