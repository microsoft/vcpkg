vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KhronosGroup/Vulkan-Headers
    REF "v${VERSION}"
    SHA512 031f0ce24f40d9d2571d6fd94d4726a23559484fb73eb314d7f9d41aff844571fdae4c6e57884315f3494b58be50b8ab2a2eb651ee8065023eeaf25a19970f47
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
