set(VCPKG_POLICY_EMPTY_PACKAGE enabled)

vcpkg_find_acquire_program(PKGCONFIG)
set(ENV{PKG_CONFIG} "${PKGCONFIG}")

vcpkg_cmake_configure(SOURCE_PATH "${CURRENT_PORT_DIR}/project")
vcpkg_cmake_build()
