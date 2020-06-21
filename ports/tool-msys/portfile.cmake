# This port represents a dependency on the MSYS2 build system.
# In the future, it is expected that this port acquires and installs MSYS2.
# Currently it is used to update MSYS2 installation and to rebuild the ports using vcpkg_acquire_msys.

set(VCPKG_POLICY_EMPTY_PACKAGE enabled)

vcpkg_acquire_msys(MSYS_ROOT)
