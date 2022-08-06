# header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KhronosGroup/Vulkan-Headers
    REF 2b55157592bf4c639b76cc16d64acaef565cc4b5
    SHA512 f1ea894ebc16d05d03addacba1e4dbd67fb5963d0fc4c084725bca5fb4e944eb7c46ef54febca8dd1530d36e9c8633001ba37ba3c24023a8d0391d030ca66ebe
    HEAD_REF v1.3.224
)

# This must be vulkan as other vulkan packages expect it there.
file(COPY "${SOURCE_PATH}/include/vulkan/" DESTINATION "${CURRENT_PACKAGES_DIR}/include/vulkan")
file(COPY "${SOURCE_PATH}/include/vk_video/" DESTINATION "${CURRENT_PACKAGES_DIR}/include/vk_video")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
