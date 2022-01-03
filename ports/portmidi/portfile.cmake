vcpkg_fail_port_install(ON_TARGET "UWP")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO PortMidi/portmidi
    REF v2.0.1
    SHA512 2c412e5b2e90fb375fbd14f22adbf31e0f3ca8ffbb421185e58bd2564da7e431395a9b50c4ba9a1330b2b17b08f0f9e31730f3a57bf8cd14210f3128c70c57a3
    HEAD_REF master
    PATCHES fix-macOS.patch
)

vcpkg_cmake_configure(SOURCE_PATH "${SOURCE_PATH}")
vcpkg_cmake_install()

vcpkg_fixup_pkgconfig()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/PortMidi)

file(INSTALL "${SOURCE_PATH}/license.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
