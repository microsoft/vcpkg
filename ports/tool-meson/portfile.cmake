# This port represents a dependency on the Meson build system.
# In the future, it is expected that this port acquires and installs Meson.
# Currently is used in ports that call vcpkg_find_acquire_program(MESON) in order to force rebuilds.

set(VCPKG_POLICY_EMPTY_PACKAGE enabled)
