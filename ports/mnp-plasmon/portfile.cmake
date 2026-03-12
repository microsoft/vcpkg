vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO galihru/mnpbem
    REF v0.1.2
    SHA512 ca6af486799cc9b9d8f0d96ab43e65daf3f3dc5d172687092bca94575c573b80ef10b897724c69d2fcc45a7b7f29d0d9d515a7a24c82f71addd4a2c80a908f68
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/c-mnp-plasmon"
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/mnp_plasmon")

vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${CURRENT_PORT_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(INSTALL "${SOURCE_PATH}/c-mnp-plasmon/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
