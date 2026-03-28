vcpkg_minimum_required(VERSION 2022-10-12)

vcpkg_buildpath_length_warning(36)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO itcv-GmbH/cpp-mcp-sdk
    REF "v${VERSION}"
    SHA512 ea32ed4199431ad639c14ccb786c19e47ade33fceb61af72b5693121ed8aa2af4276ba4faf7348a5e72dbeab84751b1099ea3eeeb6dc8088d0395bd4248f4a63
    HEAD_REF main
    PATCHES disable-clang-tidy.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DMCP_SDK_BUILD_TESTS=OFF
        -DMCP_SDK_BUILD_EXAMPLES=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/mcp_sdk")
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")


file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
