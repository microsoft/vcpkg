# error cases
# VCPKG_BASE_VERSION not set - vcpkg version is too old
set(VCPKG_BASE_VERSION_backup "${VCPKG_BASE_VERSION}")
unset(VCPKG_BASE_VERSION)
unset(VCPKG_BASE_VERSION CACHE)
unit_test_ensure_fatal_error([[vcpkg_minimum_required(VERSION 2021-01-01)]])

set(VCPKG_BASE_VERSION 2021-01-01)
unit_test_ensure_success([[vcpkg_minimum_required(VERSION 2021-01-01)]])

# reset to backup
unset(VCPKG_BASE_VERSION)
set(VCPKG_BASE_VERSION "${VCPKG_BASE_VERSION_backup}" CACHE STRING "")
