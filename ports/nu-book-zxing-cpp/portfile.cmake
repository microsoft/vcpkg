vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO zxing-cpp/zxing-cpp
    REF "v${VERSION}"
    SHA512 4058641d3c5fad80862d5ad96099348cacff0a898522191d15614f57ccb3a3696546ae0d345d8be3b4447e7e67f84a40fd5abd7087a46c24afe1824b5ce9d677
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DZXING_EXAMPLES=OFF
        -DZXING_WRITERS=OLD
        -DZXING_C_API=OFF
)

vcpkg_cmake_install()
vcpkg_fixup_pkgconfig()

vcpkg_cmake_config_fixup(
    CONFIG_PATH lib/cmake/ZXing
    PACKAGE_NAME ZXing
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(
    COMMENT "Upstream does not provide a standalone BSD-3-Clause license for libzueci. zueci.c also contains the LicenseRef-Hoehrmann-UTF-8 notice."
    FILE_LIST
        "${SOURCE_PATH}/LICENSE"
        "${SOURCE_PATH}/core/src/libzueci/zueci.c"
        "${SOURCE_PATH}/core/src/libzueci/zueci_sb.h"
)
