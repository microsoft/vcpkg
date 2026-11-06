vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO iczelia/bzip3
    REF "${VERSION}"
    SHA512 fd14877bc0cc42121f09d936f29f13a8e1ae39aecadd7536a663efdcb05bd4780d266f24661b64ae36a0347509edf8225a6a4c5223338fb915c28fb6ed25a389
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

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig"
)

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

vcpkg_install_copyright(
    FILE_LIST
        "${SOURCE_PATH}/LICENSE"
        "${SOURCE_PATH}/3rdparty/libsais-LICENSE"
)
