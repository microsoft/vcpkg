vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO agauniyal/rang
    REF v${VERSION}
    SHA512 b5211f2f1a026a5232b9289d4d6444f1e28b4d3f42602af6fb4cedc1dfff0f5c357f9de33855d1ebcdc878de7531e69b6ecd2c97583cfd6a22a99c15589bfe3e
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
