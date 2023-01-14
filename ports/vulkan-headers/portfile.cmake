# header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KhronosGroup/Vulkan-Headers
    REF 00671c64ba5c488ade22ad572a0ef81d5e64c803
    SHA512 e740688d0d2abd5c82b5bda1606e24edd87674ec7bd72ed4220c4d2d5bab30b8c993251c0b96a4c59d9e3190ddda7cb0cbf1e160aa404ef6e3c4aff23864d535
    HEAD_REF v1.3.238
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)
vcpkg_cmake_install()

# Cleanup
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
