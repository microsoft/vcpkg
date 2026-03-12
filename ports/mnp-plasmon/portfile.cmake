vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO galihru/mnpbem
    REF v0.1.1
    SHA512 197a78cb30297d0f29ab414ad5a9547aeccb9f86bb0e874659bc0dcec9bccee4366ca62cccdfef1af8044c3a159e404dec1fa5029553124953a68f96cb400122
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
