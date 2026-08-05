vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Hical61/Hical
    REF "v${VERSION}"
    SHA512 8d786708471134863106ed8d2493d00f94805cc922ae095a2cc6fab1cfaadb49dd94461b0ae884a58af7f61f30102be7dcd81429eb9e4a7d8a59a9d232b6ff77
    HEAD_REF main
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        database HICAL_WITH_DATABASE
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DHICAL_BUILD_TESTS=OFF
        -DHICAL_BUILD_EXAMPLES=OFF
        -DHICAL_USE_SYSTEM_PICOHTTPPARSER=ON
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(
    PACKAGE_NAME hical
    CONFIG_PATH lib/cmake/hical
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
