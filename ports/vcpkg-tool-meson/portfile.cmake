# This port represents a dependency on the Meson build system.
# In the future, it is expected that this port acquires and installs Meson.
# Currently is used in ports that call vcpkg_find_acquire_program(MESON) in order to force rebuilds.

set(VCPKG_POLICY_CMAKE_HELPER_PORT enabled)

configure_file("${CMAKE_CURRENT_LIST_DIR}/vcpkg-port-config.cmake" "${CURRENT_PACKAGES_DIR}/share/${PORT}/vcpkg-port-config.cmake" @ONLY)
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/vcpkg_configure_meson.cmake"
             "${CMAKE_CURRENT_LIST_DIR}/vcpkg_install_meson.cmake"
             "${CMAKE_CURRENT_LIST_DIR}/meson-intl.patch"
             "${CMAKE_CURRENT_LIST_DIR}/python-lib-dep.patch"
             "${CMAKE_CURRENT_LIST_DIR}/11259.diff"
             DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

file(WRITE "${CURRENT_PACKAGES_DIR}/share/meson/version.txt" "${VERSION}") # For vcpkg_find_acquire_program

file(INSTALL "${VCPKG_ROOT_DIR}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
