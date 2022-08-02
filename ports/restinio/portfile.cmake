vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO stiffstream/restinio
    REF 03e69fe720c91c65b8cfe93f463dc6063ab287bd # v.0.6.16
    SHA512 fc333181b4d9c25d8b759663af2e8e805a2a9eb81c0808e950d949e67c15b268e3c2a230fb34ffd4e4c4571004e1aa2136749f7d5ce92c43288089b171637390
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/vcpkg"
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/restinio)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib" "${CURRENT_PACKAGES_DIR}/debug")
# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
