if(VCPKG_TARGET_IS_UWP)
    vcpkg_check_linkage(ONLY_DYNAMIC_CRT)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Waffle0823/SteamworksSDK
    REF "v${VERSION}"
    SHA512 93dbd8c7bdf5aa153c7e910b11dd6657fce7f32b8be86a64c7d7851251657c8f15504f251c971c80c1f2d8fe617df6354c611266f63d3b23ed42d24ad9c2d1b9
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME SteamworksSDK CONFIG_PATH lib/cmake/SteamworksSDK)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
