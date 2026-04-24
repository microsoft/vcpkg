if(VCPKG_TARGET_IS_UWP)
    vcpkg_check_linkage(ONLY_DYNAMIC_CRT)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Waffle0823/SteamworksSDK
    REF "v${VERSION}"
    SHA512 d51477649d6620e7376038f2c5f3cdbe4f91888a7c6ce5f6b711ed1fa7b9d726712f381e5390f977319f089616e3f49a1ec3d4c6d853f93e949dfe86fd676c86
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME SteamworksSDK CONFIG_PATH lib/cmake/SteamworksSDK)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
