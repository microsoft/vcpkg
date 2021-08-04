# header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KhronosGroup/Vulkan-Hpp
    REF v1.2.184
    SHA512 564bb5fd3b89fc8078e3c4d99c719f4d62166d78891bc529d6d07add1843137ec8f62a92dbdcfa9ffa8a9677fba41da1b591a033c61b27c43c70c25be32c3205
    HEAD_REF master
)

file(COPY ${SOURCE_PATH}/vulkan/vulkan.hpp DESTINATION ${CURRENT_PACKAGES_DIR}/include/vulkan)

# Handle copyright
configure_file(${SOURCE_PATH}/LICENSE.txt ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)
