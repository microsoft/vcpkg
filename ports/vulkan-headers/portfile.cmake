vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KhronosGroup/Vulkan-Headers
    REF "vulkan-sdk-${VERSION}"
    SHA512 5cc23875fc4f548e6669936d290a05a09da36c2e6b73f1c904fa8b750a3bb695c7ef197ef9a0b788d1bb51021d4dd464f847fcec9909cb867618558b34fbcd6b
    HEAD_REF main
    PATCHES fix-headers.patch
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
