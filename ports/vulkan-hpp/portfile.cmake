# header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KhronosGroup/Vulkan-Hpp
    REF ef609a2f77dd1756e672712f264e76b64acdba61 #v1.3.231
    SHA512 071cf0d321475a55ecb6eed5874a316daac64a62265f05566c112317ae19cc569e7dfb14ceb9e5c6716a004e2cc621c167d0ffe30faf506096f362c1ed55fafd
    HEAD_REF master
)

file(COPY "${SOURCE_PATH}/vulkan/vulkan.hpp" DESTINATION "${CURRENT_PACKAGES_DIR}/include/vulkan")

# Handle copyright
configure_file("${SOURCE_PATH}/LICENSE.txt" "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright" COPYONLY)
