vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KhronosGroup/Vulkan-Headers
    REF bae9700cd9425541a0f6029957f005e5ad3ef660
    SHA512 b1a51cb868563bf044c65cab8411547b8a08ea21998f01e5be53027217ddd18ff6907d78490c08e3f14865c53436ddf092811726ae3df23a29f8edd614bdb95b
    HEAD_REF v1.3.250
)

set(VCPKG_BUILD_TYPE release) # header-only port

vcpkg_cmake_configure(SOURCE_PATH "${SOURCE_PATH}")
vcpkg_cmake_install()
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
