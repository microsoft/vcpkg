vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO remz1337/tree-similarity
    REF 6de059939ae27fbe68a5809b21bac7c5dfe5f0ee
    SHA512 beae8c0d12964d13623575a9599e17fd3ef849737e4fc6396d64288c74782b89580b8d2643432c6c3d5768e1042c6af9b824a3457883833b942a8faf451b4048
    HEAD_REF vcpkg
)

vcpkg_cmake_configure(SOURCE_PATH "${SOURCE_PATH}")

vcpkg_cmake_install()
#vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/tree-similarity)
#file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

vcpkg_fixup_pkgconfig()
