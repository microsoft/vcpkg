set(VCPKG_POLICY_DLLS_IN_STATIC_LIBRARY enabled)

if(VCPKG_TARGET_IS_UWP)
    vcpkg_check_linkage(ONLY_DYNAMIC_CRT)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Waffle0823/SteamworksSDK
    REF "v${VERSION}"
    SHA512 910d4e6645fd6185a055ebcb9942b777fe4347646f51906b9b26096975e4a46bae8d68062572ed017eb4105cb3692f53f5ecd04e6d2b96b51d25fa93344777da
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME SteamworksSDK CONFIG_PATH lib/cmake/SteamworksSDK)

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/include/steam/lib"
)

if(NOT VCPKG_TARGET_IS_WINDOWS)
    file(REMOVE_RECURSE
        "${CURRENT_PACKAGES_DIR}/lib"
        "${CURRENT_PACKAGES_DIR}/debug/lib"
    )
endif()

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
