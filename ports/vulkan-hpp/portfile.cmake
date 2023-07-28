# header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KhronosGroup/Vulkan-Hpp
    REF "v${VERSION}"
    SHA512 68c26541961881a3e6c9287719d8b50ccb6a9e44b5c0213a780db37dc7b107aec736abdeda19c74837f37f490662cf40c4cc4c2d3da17eeb5f84923fcdfc2d6e
    HEAD_REF master
)

file(COPY "${SOURCE_PATH}/vulkan/vulkan.hpp" DESTINATION "${CURRENT_PACKAGES_DIR}/include/vulkan")

# Handle copyright
configure_file("${SOURCE_PATH}/LICENSE.txt" "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright" COPYONLY)
