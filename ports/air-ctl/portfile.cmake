vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO  inie0722/CTL
    REF v1.1.2
    SHA512 280e1d6099bdb835b7fec5824eef1159c813e99fecb333229f54cf5345e3379fec06a36bc657b5c8174b1b50cf6d8ee358029ef8525905f6d715d9a6105c2729
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
