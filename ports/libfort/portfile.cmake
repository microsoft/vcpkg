vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO seleznevae/libfort
    REF b1c32b67511f4612996b287a1ef4a9df012521d2 # v0.4.2
    SHA512 56d3bd00b8a72a5f9deb9bca9a325e100319aed55e10321d04243d8a2a94c0fa513ada1b13bc59957af01b1f2c5f1655304a4a608e118cbeb65d2b4527f102d0
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DFORT_ENABLE_TESTING=OFF
        -DFORT_ENABLE_ASTYLE=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/libfort)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
