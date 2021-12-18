# header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KhronosGroup/Vulkan-Headers
    REF v1.2.184
    SHA512 95ee241ca82ba4373dc53aefec36839b6a08478434742bd8de6750d875a7a5fcb2225afae5f6f400a7b302af87da7e226b725be5435236694e816e141a3b24ef
    HEAD_REF master
)

# This must be vulkan as other vulkan packages expect it there.
file(COPY "${SOURCE_PATH}/include/vulkan/" DESTINATION "${CURRENT_PACKAGES_DIR}/include/vulkan")
file(COPY "${SOURCE_PATH}/include/vk_video/" DESTINATION "${CURRENT_PACKAGES_DIR}/include/vk_video")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
