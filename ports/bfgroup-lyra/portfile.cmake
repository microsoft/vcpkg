vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO bfgroup/Lyra
    REF 1.5.1
    SHA512 e349c57614fe18cfee49b6a3977f133de3e567aa6b1c148abf9510432f7db34b75488739850e48c7943a15151fe2eedb129179d8d73eb61fb4f9a11c54b61086
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(
    PACKAGE_NAME lyra
    CONFIG_PATH share/lyra/cmake
)

# Library is header-only, so no debug content.
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

file(INSTALL "${SOURCE_PATH}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
