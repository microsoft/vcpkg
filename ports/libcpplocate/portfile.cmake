vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO cginternals/cpplocate
  REF v2.3.0
  SHA512 4028d552d0c3c0161d5dd5aea27bb22f0c61297a4b461a067c082cfcf84e3a709c9895453e750d819433529089011c2512293b2064c42bb5ba11f957eebc2206
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
