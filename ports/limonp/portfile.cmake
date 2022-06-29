vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO playgithub/limonp
    REF 2d5998fedf23e5d3472258f6bde44087ec828680
    SHA512 b5e1a956fd534fe75796eb2555960507482765a7d0d76ca833dbfa06f8a51fb2aa93c781f68887296224855560e14494655aa5fb5e668174b36b4fdd983f43bd
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
