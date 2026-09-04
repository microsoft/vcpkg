if(VCPKG_TARGET_IS_LINUX)
    message("Warning: `glaze` requires Clang 17+ or GCC 13+ on Linux")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO stephenberry/glaze
    REF "v${VERSION}"
    SHA512 fa853b4271cf7d490c306a55b7615ed0d5f57f6ecc2f35310cf8b8b2660240c42e83fd60040ac0ee25fae17ba92f500a6d886c9fb45972b3dbdbc017562750f5
    HEAD_REF main
    PATCHES
        001-fix-asio.patch
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
