vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO rioki/c9y
    REF v0.6.2
    SHA512 13a7d820767dd3363557c64cf6d555778d91a5403ed4c2725c8a531adae0f010bf87076b09aa661880e73724dfb3dce05289364578b9a70f3409b72845705c96
    )

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/c9y)
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL "${SOURCE_PATH}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
