vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO serge-sans-paille/frozen
    REF "${VERSION}"
    SHA512 644b29f60458fc5193a3fb16a347c190f9694d1bdbc75202aafe8d43eb72ce0433bbeaeb692f8ca485000d68b451ddc0236a1880ebbd64477f73198043d046b3
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
      -Dfrozen.benchmark=OFF
      -Dfrozen.coverage=OFF
      -Dfrozen.installation=ON
      -Dfrozen.tests=OFF
)
vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH share/cmake/frozen)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
