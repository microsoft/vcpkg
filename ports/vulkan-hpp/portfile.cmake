# header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KhronosGroup/Vulkan-Hpp
    REF 3de6ccafd688df4be0c7830c23167535c511594d #v1.2.203
    SHA512 a3d3058afd88d9313a676acf49d908f0b00010b34de1e4b1263c3e20079f1ba829c050e5c26c835963b8f117bc9b118e4dea2ad295867da7b657a0890f46fecc
    HEAD_REF master
)

file(COPY "${SOURCE_PATH}/vulkan/vulkan.hpp" DESTINATION "${CURRENT_PACKAGES_DIR}/include/vulkan")

# Handle copyright
configure_file("${SOURCE_PATH}/LICENSE.txt" "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright" COPYONLY)
