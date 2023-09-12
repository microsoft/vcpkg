vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO no1msd/mstch
  REF ff459067bd02e80dc399006bb610238223d41c50 #1.0.2
  SHA512 b01f4c3e39a40fc9a6accc81ecbfac4b8a9ce1c2ec3df441a16039f4bf126dfeef83f87d3a5e9ec03dc133a1c5f54f5bc931479915e8a92bbfc8ebbc87c8e4dd
  HEAD_REF master
  PATCHES do-not-force-release.patch
)

vcpkg_cmake_configure(
  SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/mstch)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_copy_pdbs()

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
