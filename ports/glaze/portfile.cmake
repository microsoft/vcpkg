if(VCPKG_TARGET_IS_LINUX)
    message("Warning: `glaze` requires Clang15+ or GCC 12+ on Linux")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO stephenberry/glaze
    REF "v${VERSION}"
    SHA512 fb45220afde0b6374f6d864baa7fb649583e304a31914036aa7673adf2a72aa3944926f9a8f3e71fea4ec5f6655afa0a8fdcd42c698d98451b0ac1db7c15aa39
    HEAD_REF main
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        ssl     glaze_ENABLE_SSL
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
