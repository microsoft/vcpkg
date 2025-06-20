if(VCPKG_TARGET_IS_LINUX)
    message("Warning: `glaze` requires Clang15+ or GCC 12+ on Linux")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO stephenberry/glaze
    REF "v${VERSION}"
    SHA512 61f7323b2b211b44c2e5053a19aa10ddf1271ed87940dd05f74f230297a68c75262bbb4a0db01205b996fd32823e27927f18b1c88ca03a575d7ac58ec315d055
    HEAD_REF main
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        ssl glaze_ENABLE_SSL
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -Dglaze_DEVELOPER_MODE=OFF
        -Dglaze_BUILD_EXAMPLES=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
