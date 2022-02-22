vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO cginternals/cpplocate
  REF 23aeb69c23848ff52456179374b9dfc1ede357bf # 2.3.0 in CMakeLists.txt "META_VERSION_*"
  SHA512 3ab7074a30b089574f12e44842e4894788e5a19ad2a496c5e8307c479b378171974087ff3050e6dffe6e4fc2c2873310cefb191cb1a41bd6c0a83e32ba46ddcc
  HEAD_REF master
  PATCHES
    fix-install-paths.patch
)

vcpkg_cmake_configure(
  SOURCE_PATH "${SOURCE_PATH}"
  OPTIONS
        -DOPTION_BUILD_TESTS=OFF
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(
  PACKAGE_NAME cpplocate
  CONFIG_PATH share/cpplocate/cmake/cpplocate
  DO_NOT_DELETE_PARENT_CONFIG_PATH
)

vcpkg_cmake_config_fixup(
  PACKAGE_NAME liblocate
  CONFIG_PATH share/cpplocate/cmake/liblocate
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/cpplocate/cmake")

# Patched liblocate config file needs moving to the correct directory
file(RENAME
  "${CURRENT_PACKAGES_DIR}/share/cpplocate/liblocate-config.cmake"
  "${CURRENT_PACKAGES_DIR}/share/liblocate/liblocate-config.cmake"
)

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
