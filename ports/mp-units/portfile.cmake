if ("version-2" IN_LIST FEATURES)
  vcpkg_from_github(
      OUT_SOURCE_PATH SOURCE_PATH
      REPO mpusz/units
      HEAD_REF v2_framework
      REF a6434e6b602b3ca05103848ccc94da04cf850ac9
      SHA512 92f29b8b72cfc757be07a23d6aa5bfddbcc6ac34dbf60f494ace7772a2b83f692afeb72bef8324bbb06b131bd851b7bd5e5b42752ba0f84d7e481b1605190a98
  )
else ()
  vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mpusz/units
    REF v0.7.0
    SHA512 72175f34f358d0741650ce9c8a7b28fced90cc45ddd3f1662ae1cb9ff7d31403ff742ee07ab4c96bd2d95af714d9111a888cf6acccb91e568e12d1ef663b2f64
    PATCHES
        config.patch
  )
endif ()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/src"
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/${PORT}")

# Handle copyright/readme/package files
file(INSTALL "${SOURCE_PATH}/LICENSE.md" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
file(INSTALL "${SOURCE_PATH}/README.md" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug"
                    "${CURRENT_PACKAGES_DIR}/lib") # Header only