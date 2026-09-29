if(VCPKG_TARGET_IS_LINUX)
    message("Warning: `glaze` requires Clang 17+ or GCC 13+ on Linux")
endif()

vcpkg_download_distfile(ARM64_MSVC_PATCH
    URLS "https://github.com/stephenberry/glaze/commit/57d78dd5d330db6b75367d303970ffd2e46106e7.diff?full_index=1"
    FILENAME "glaze-57d78dd5d330db6b75367d303970ffd2e46106e7.diff"
    SHA512 39c8c00d02e30893268c6e830e772c8b2cb83f3d06f77c9d5e5b005a3c9ce66bf0534b346ea474a67f5ea9a9086f56086a8e063735eabd0089ba040197f0326d
)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO stephenberry/glaze
    REF "v${VERSION}"
    SHA512 5c20852e51fad9860a181a07ca8dd5b0d3654fc45836a8ba23129a1c1ab0dec2635d1f2da3a752be5dcee374df79ceffee6c60f29efc7cdfa4c45863d770fec0
    HEAD_REF main
    PATCHES
        001-fix-asio.patch
        "${ARM64_MSVC_PATCH}"
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        networking      glaze_ENABLE_NETWORKING
        ssl             glaze_ENABLE_SSL
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

if("networking" IN_LIST FEATURES)
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/glaze/ext/glaze_asio.hpp" "#if __has_include(<asio.hpp>) && !defined(GLZ_USE_BOOST_ASIO)" "#if 1")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
file(INSTALL "${CURRENT_PORT_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
