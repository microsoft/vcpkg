vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO David-Haim/concurrencpp
  REF v.0.1.3
  SHA512 2f4530ba93d768a7a1ae14c532c8ef443745e48cceeca8a0e9da9f91633876ae4971caad70eeff9e18c7a45e8cf7c0b7bb79720a62026850244fb2377ad10df7
  HEAD_REF master
  PATCHES
    fix-include-path.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/concurrencpp-0.1.3)

file(INSTALL ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/concurrencpp RENAME copyright)
