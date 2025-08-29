if(VCPKG_TARGET_IS_LINUX)
    message("Warning: `glaze` requires Clang15+ or GCC 12+ on Linux")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO stephenberry/glaze
    REF "v${VERSION}"
    SHA512 23ddfebd05cb54a81677dc314a2b21c74cc2d35c362262d99178ecd64067aac2cb0cee14b1cd91de4d45c6980758f80e218d1d5f7e3f15f0bf00583b675ef8de
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
