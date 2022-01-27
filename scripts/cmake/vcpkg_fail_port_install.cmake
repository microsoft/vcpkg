#[===[.md:
# vcpkg_fail_port_install

This function is deprecated, please use `supports` field in manifest file or directly add `${PORT}:${FAILED_TRIPLET}=fail` to _scripts/ci.baseline.txt_ instead.
#]===]

message("${Z_VCPKG_BACKCOMPAT_MESSAGE_LEVEL}" "vcpkg_fail_port_install has been removed and all values should be moved by adding `supports` field to manifest file or directly adding `${PORT}:${FAILED_TRIPLET}=fail` to _scripts/ci.baseline.txt_.\nPlease remove `vcpkg_fail_port_install(...)`.\n")
