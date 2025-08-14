vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO iczelia/bzip3
    REF ${VERSION}
    SHA512 4864db82af7bfb4b9753a4dfc6b966fb707607b5e5693134b6771a4c745a2cbe5767928c54f36ba89181d59dc2882d5630379c60655e23d0e7b2a0997d655aef
    HEAD_REF master
    PATCHES
        disable-man.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS options
    FEATURES
        tools    BZIP3_BUILD_APPS
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${options}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/bzip3)
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
