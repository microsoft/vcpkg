if(VCPKG_TARGET_IS_LINUX)
    message("Warning: `glaze` requires Clang 17+ or GCC 13+ on Linux")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO stephenberry/glaze
    REF "v${VERSION}"
    SHA512 750f1b0cec2cf1242f4627215bf156d56cce659e15a7e9ba1c407ff9bf56bb9cd028b92337bb98710ceb106ba687db0c4557764171cabc5feb53c74eb363af29
    HEAD_REF main
    PATCHES
        001-fix-asio.patch
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
        -Dglaze_EETF_FORMAT=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup()

vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/glaze/ext/glaze_asio.hpp" "#if __has_include(<asio.hpp>) && !defined(GLZ_USE_BOOST_ASIO)" "#if 1")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
