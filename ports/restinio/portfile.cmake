vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO stiffstream/restinio
    REF 3bbbc97f572efc62dcf8ebfe3baf919593c22d81 # v.0.6.15
    SHA512 3a89d72bad4383b83bcfe8bbe16e12f7c08367dc3dfb2feff5642334d2bd5df3c75e5b25c4402c54d4279c45d5ab5997992fba18c3099772b6145fa90af7c808
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/vcpkg"
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/restinio)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib" "${CURRENT_PACKAGES_DIR}/debug")
# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
