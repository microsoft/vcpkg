# This port represents a dependency on the Meson build system.
# In the future, it is expected that this port acquires and installs Meson.
# Currently is used in ports that call vcpkg_find_acquire_program(MESON) in order to force rebuilds.

set(VCPKG_POLICY_CMAKE_HELPER_PORT enabled)

set(patches
  meson-intl.patch
  adjust-python-dep.patch
  adjust-args.patch
  remove-freebsd-pcfile-specialization.patch
)
set(scripts
  vcpkg-port-config.cmake
  vcpkg_configure_meson.cmake
  vcpkg_install_meson.cmake
  meson.template.in
)
set(to_hash 
  "${CMAKE_CURRENT_LIST_DIR}/vcpkg.json"
  "${CMAKE_CURRENT_LIST_DIR}/portfile.cmake"
)
foreach(file IN LISTS patches scripts)
  set(filepath  "${CMAKE_CURRENT_LIST_DIR}/${file}")
  list(APPEND to_hash "${filepath}")
  file(COPY "${filepath}" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
endforeach()

set(meson_path_hash "")
foreach(filepath IN LISTS to_hash)
  file(SHA1 "${filepath}" to_append)
  string(APPEND meson_path_hash "${to_append}")
endforeach()
string(SHA512 meson_path_hash "${meson_path_hash}")

string(SUBSTRING "${meson_path_hash}" 0 6 MESON_SHORT_HASH)
list(TRANSFORM patches REPLACE [[^(..*)$]] [["${CMAKE_CURRENT_LIST_DIR}/\0"]])
list(JOIN patches "\n            " PATCHES)
configure_file("${CMAKE_CURRENT_LIST_DIR}/vcpkg-port-config.cmake" "${CURRENT_PACKAGES_DIR}/share/${PORT}/vcpkg-port-config.cmake" @ONLY)

vcpkg_install_copyright(FILE_LIST "${VCPKG_ROOT_DIR}/LICENSE.txt")

include("${CURRENT_PACKAGES_DIR}/share/${PORT}/vcpkg-port-config.cmake")
