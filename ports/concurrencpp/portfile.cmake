vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO David-Haim/concurrencpp
  REF v.0.1.4
  SHA512 494680b8a642d9c2ad1e31a6b52ecac672af7b8ba2213fc6b0d525968bd27122c9b3c7105286af22fd6ebfa3cee4bb3b2c8948062418ad8419a305f7c3df0d4b
  HEAD_REF master
  PATCHES
    fix-include-path.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/concurrencpp-0.1.4)

file(INSTALL ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/concurrencpp RENAME copyright)
