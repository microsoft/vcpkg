# header-only library
include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KhronosGroup/SPIRV-Headers
    REF 1.5.1.corrected
    SHA512 92447b1b1eca6f0253265f36d67b00c0c79e93f6a707e27bd8239bd2f693c468a92b7f7c3bb3fde6bb091383baaff42d3b0bbfeb9ff5f952d8a0b9626b03848e
    HEAD_REF master
)

# This must be spirv as other spirv packages expect it there.
# Copy header files
file(COPY ${SOURCE_PATH}/include/spirv/ DESTINATION ${CURRENT_PACKAGES_DIR}/include/spirv)

# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/spirv-headers)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/spirv-headers/LICENSE ${CURRENT_PACKAGES_DIR}/share/spirv-headers/copyright)
