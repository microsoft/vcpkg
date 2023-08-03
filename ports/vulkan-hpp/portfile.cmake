# header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KhronosGroup/Vulkan-Hpp
    REF "v${VERSION}"
    SHA512 3783268de9c137218453431d03d4bb30a222dc7e94d7ca4eeab896884c8cada3e7a095f432e939efe8c6341773e64656dc141c5ce0f5ef0f49e77f7322e232f6
    HEAD_REF master
)

file(COPY "${SOURCE_PATH}/vulkan/vulkan.hpp" DESTINATION "${CURRENT_PACKAGES_DIR}/include/vulkan")

# Handle copyright
configure_file("${SOURCE_PATH}/LICENSE.txt" "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright" COPYONLY)
