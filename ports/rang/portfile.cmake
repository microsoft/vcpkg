vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO agauniyal/rang
    REF v3.2
    SHA512 f579aaf3bddbfa2325dd31bdbe7c32598af8a340fee62c3a1e7ed1cf189af2808b7838a5fb13b3765279ddd1e7481f6229da72e72218a4916455cf3ae12b5a68
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/rang)
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)