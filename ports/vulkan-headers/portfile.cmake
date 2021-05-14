# header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KhronosGroup/Vulkan-Headers
    REF v1.2.157
    SHA512 ab0051251ba7491b7d5720c78a187c0e75fc3056a2ad9718cbade56ea94a9ce6ac6b6d7bd8c3e998669c7f6ff5de0ea4d1b1d05df0dab6cf943c33a32d66b832
    HEAD_REF master
)

# This must be vulkan as other vulkan packages expect it there.
file(COPY "${SOURCE_PATH}/include/vulkan/" DESTINATION "${CURRENT_PACKAGES_DIR}/include/vulkan")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
