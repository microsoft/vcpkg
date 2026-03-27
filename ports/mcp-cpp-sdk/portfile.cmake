vcpkg_minimum_required(VERSION 2022-10-12)

vcpkg_buildpath_length_warning(36)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO itcv-GmbH/cpp-mcp-sdk
    REF "v${VERSION}"
    SHA512 5d2687384a951c50b9873e8e0b9fcd4110a5dc0f76b581f2cd95dbac2a4e68ca66289b4d1e82d8b52ad0eed6893d5d729517f8f4aa40e61755dcdf8bcb003a3d
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
