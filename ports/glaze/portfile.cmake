if(VCPKG_TARGET_IS_LINUX)
    message("Warning: `glaze` requires Clang 17+ or GCC 13+ on Linux")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO stephenberry/glaze
    REF "v${VERSION}"
    SHA512 7e721ad5719478fa78570fe6a57a2f45cd2815234c1c0eea2e710c1c324980c20d0eecbb4856288ee248a6f1cf930815ef203d85ff26602969d341e04cdf7602
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
