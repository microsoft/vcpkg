# header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KhronosGroup/Vulkan-Headers
    REF 16847a61009f23b73b6de658a64e42926efc1ea9 #v1.3.221
    SHA512 c9ce3aeb51a645c538b490c758112c5c1fc8951a705e1ffa142d415495b71259a7958098f07aec8eb685436c0ec526a68e017b13928c58441127edf333f8d2f9
    HEAD_REF master
)

# This must be vulkan as other vulkan packages expect it there.
file(COPY "${SOURCE_PATH}/include/vulkan/" DESTINATION "${CURRENT_PACKAGES_DIR}/include/vulkan")
file(COPY "${SOURCE_PATH}/include/vk_video/" DESTINATION "${CURRENT_PACKAGES_DIR}/include/vk_video")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
