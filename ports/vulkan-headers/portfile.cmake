vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KhronosGroup/Vulkan-Headers
    REF "vulkan-sdk-${VERSION}"
    SHA512 613a330e37cb4c4c4d17d77e10d47e7482a6cd143a1ae618fdd0f2f0af05b1cdb4ddeebc44f6395d6dee5766a322b9ea9a16ad3cf9e4fffef30d804b976093ee
    HEAD_REF main
)

set(VCPKG_BUILD_TYPE release) # header-only port

vcpkg_cmake_configure(SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DVULKAN_HEADERS_ENABLE_MODULE=OFF
        -DVULKAN_HEADERS_ENABLE_TESTS=OFF
)
vcpkg_cmake_install()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.md")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
