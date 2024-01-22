# This port represents a dependency on the Meson build system.
# In the future, it is expected that this port acquires and installs Meson.
# Currently is used in ports that call vcpkg_find_acquire_program(MESON) in order to force rebuilds.

set(VCPKG_POLICY_CMAKE_HELPER_PORT enabled)

set(files 
  vcpkg.json
  portfile.cmake
  vcpkg-port-config.cmake
  vcpkg_configure_meson.cmake
  vcpkg_install_meson.cmake
  meson-intl.patch
  adjust-python-dep.patch
  adjust-args.patch
  remove-freebsd-pcfile-specialization.patch
  meson.template.in
)

set(MESON_PATH_HASH "")
foreach(to_hash IN LISTS files)
  file(SHA1 ${CMAKE_CURRENT_LIST_DIR}/${to_hash} to_append)
  string(APPEND MESON_PATH_HASH "${to_append}")
endforeach()
string(SHA512 MESON_PATH_HASH "${MESON_PATH_HASH}")

configure_file("${CMAKE_CURRENT_LIST_DIR}/vcpkg-port-config.cmake" "${CURRENT_PACKAGES_DIR}/share/${PORT}/vcpkg-port-config.cmake" @ONLY)
file(COPY "${CMAKE_CURRENT_LIST_DIR}/vcpkg_configure_meson.cmake"
          "${CMAKE_CURRENT_LIST_DIR}/vcpkg_install_meson.cmake"
          "${CMAKE_CURRENT_LIST_DIR}/meson-intl.patch"
          "${CMAKE_CURRENT_LIST_DIR}/adjust-python-dep.patch"
          "${CMAKE_CURRENT_LIST_DIR}/adjust-args.patch"
          "${CMAKE_CURRENT_LIST_DIR}/remove-freebsd-pcfile-specialization.patch"
          "${CMAKE_CURRENT_LIST_DIR}/meson.template.in"
          DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

file(WRITE "${CURRENT_PACKAGES_DIR}/share/meson/version.txt" "${VERSION}") # For vcpkg_find_acquire_program

vcpkg_install_copyright(FILE_LIST "${VCPKG_ROOT_DIR}/LICENSE.txt")

include("${CURRENT_PACKAGES_DIR}/share/${PORT}/vcpkg-port-config.cmake")