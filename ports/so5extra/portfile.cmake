vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO stiffstream/so5extra
    REF be3fe020c30a7e5b3d7d2ac763c83e9a5dc7941f # v.1.5.2
    SHA512 49286808c189af9de1736e6bf3ac58273801d81c2123da4e94836a9ae83d68a8b55414a2c2373195d9c2af6a0ea7d4244754310869f6b2fab59c13547bdf478b
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/dev/so_5_extra"
    OPTIONS
        -DSO5EXTRA_INSTALL=ON
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/so5extra)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib" "${CURRENT_PACKAGES_DIR}/debug")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/so5extra" RENAME copyright)

