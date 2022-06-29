vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO playgithub/limonp
    REF 71688bddb6089abc6bc38d8ee420e0feb1d21790
    SHA512 f58919a564f43337836ffaf8b3c562a8e7c9ab8a58f3455f727f3b4461c723f25a6b557a864a6b823eac7707e1b2c2b43ac6335a0d64ed72b06350fda0b4270a
)
vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

# # Moves all .cmake files from /debug/share/limonp/ to /share/limonp/
# # See /docs/maintainers/ports/vcpkg-cmake-config/vcpkg_cmake_config_fixup.md for more details
# When you uncomment "vcpkg_cmake_config_fixup()", you need to add the following to "dependencies" vcpkg.json:
#{
#    "name": "vcpkg-cmake-config",
#    "host": true
#}
# vcpkg_cmake_config_fixup(CONFIG_PATH cmake TARGET_PATH share/limonp)

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
