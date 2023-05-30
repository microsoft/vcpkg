vcpkg_minimum_required(VERSION 2023-04-07)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jpenuchot/ctbench
    REF v1.3.1
    SHA512 59c633b08de0517c4fe6fd51f7468f7e7eab9131bd190d9b4d1b471a11e767da225f1eca797c2aa9c6b55b88377db48a525afce8d166486a06b989afa10cc2de
    HEAD_REF main
)

vcpkg_cmake_configure(SOURCE_PATH ${SOURCE_PATH})
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/ctbench)
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/ctbench" RENAME copyright)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
