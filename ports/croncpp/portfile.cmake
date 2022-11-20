
vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO mariusbancila/croncpp
  REF 11cce4666a06c40346c7ba380ddd90c53806809d #master on 9/4/2020
  SHA512 8f4d892ce90d8eca3711b21728bb599bf64857b20c0b143c5277687d0b6e5d5b8bf3e6dc7f9e8d028ba4e5ee711a5a9e750bcc2f771177d2f659c0c19e12207a
  HEAD_REF master
  PATCHES
    0001-fix-cmake.patch
    no-test.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
      -DBUILD_TESTS=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
