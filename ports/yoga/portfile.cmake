vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO facebook/yoga
    REF v1.19.0
    SHA512 B1CB1F23CF9B5DD2491B6883CAF8FB47E264B736C94F6AA6655E9A6F641664B4BCEEB48F74C98B955F0EE02BA2E0AE8E01539A928ABB4B81FAE13ED3B57287CA
    HEAD_REF master
    PATCHES
        add-project-declaration.patch
        Export-unofficial-yoga-config.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME unofficial-yoga)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
