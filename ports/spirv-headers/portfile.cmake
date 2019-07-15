# header-only library
include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KhronosGroup/SPIRV-Headers
    REF c4f8f65792d4bf2657ca751904c511bbcf2ac77b
    SHA512 750af53a70f6f890657735ab0e2db5ae3dd8d612480efc2247753993752f687e22a0bdd65296c5751daf284604fe3dc9ee0a94feae88761a0e64adc64e6d17a4
    HEAD_REF master
)

# This must be spirv as other spirv packages expect it there.
# Copy header files
file(COPY ${SOURCE_PATH}/include/spirv/ DESTINATION ${CURRENT_PACKAGES_DIR}/include/spirv)

# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/spirv-headers)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/spirv-headers/LICENSE ${CURRENT_PACKAGES_DIR}/share/spirv-headers/copyright)
