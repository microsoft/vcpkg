vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO PortMidi/portmidi
    REF v2.0.2
    SHA512 36c43dc1f8b304c36de1c4672b8d2abe67c72dd8ea46044ebd479896a0e346f00207d4483e08701a04cdf3f342790c874f8a1c07d71d5d55d763bf97a1276021
    HEAD_REF master
)

vcpkg_cmake_configure(SOURCE_PATH "${SOURCE_PATH}")
vcpkg_cmake_install()

vcpkg_fixup_pkgconfig()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/PortMidi)

file(INSTALL "${SOURCE_PATH}/license.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
