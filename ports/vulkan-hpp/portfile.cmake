# header-only library

include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KhronosGroup/Vulkan-Hpp
    REF 5ce8ae7fd0d9c0543d02f33cfa8a66e6a43e2150
    SHA512 dc58332f5075f0b4d001abd4e78664be099509b8cee525a211aa33599f2351bf5e200fef37dccc84895d8f7a056f075ae3cf404f9aac7281970ff903e4a67a96
    HEAD_REF master
)

file(COPY ${SOURCE_PATH}/vulkan/vulkan.hpp DESTINATION ${CURRENT_PACKAGES_DIR}/include/vulkan)

# Handle copyright
configure_file(${SOURCE_PATH}/LICENSE.txt ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)
