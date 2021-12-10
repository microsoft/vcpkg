vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO bombela/backward-cpp
  REF 3bb9240cb15459768adb3e7d963a20e1523a6294 # v1.6
  SHA512 5f3998202e87e43ae60d3b3de70e8d48284284135183a85aa59aad25c77eea1f6664b37b65131b383270dfa51cfe205ea5b1707b922015ed88771073ad8e79e4
  HEAD_REF master
  )

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_cmake_config_fixup(CONFIG_PATH lib/backward)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

# # Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/backward" RENAME copyright)
