# header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KhronosGroup/Vulkan-Headers
    REF 52a76fd0a693708eb8c25bd0ab7a1008091f64d4 #v1.2.203
    SHA512 e3a337f0f1d0d003db522385b40ed187416e2246e64718b7d980ecdd92ac400a9e96b06dbb52c6f09cf7725772b5772727efb61c0e2f3a67989fe693fa569d38
    HEAD_REF master
)

# This must be vulkan as other vulkan packages expect it there.
file(COPY "${SOURCE_PATH}/include/vulkan/" DESTINATION "${CURRENT_PACKAGES_DIR}/include/vulkan")
file(COPY "${SOURCE_PATH}/include/vk_video/" DESTINATION "${CURRENT_PACKAGES_DIR}/include/vk_video")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
