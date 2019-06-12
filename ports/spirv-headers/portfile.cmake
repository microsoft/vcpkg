# header-only library
include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KhronosGroup/SPIRV-Headers
    REF 03a081524afabdde274d885880c2fef213e46a59
    SHA512 27f0a4b5efbe2931c0ff5d50e5fb5bd78fe0a735ad48a08db72c8914f2de05f5d5c507134e0a090bb5a7d88e2f8c1a0bdbf51a0bc4b9fe3bf372da7000ca0b98
    HEAD_REF master
)

# This must be spirv as other spirv packages expect it there.
# Copy header files
file(COPY ${SOURCE_PATH}/include/spirv/ DESTINATION ${CURRENT_PACKAGES_DIR}/include/spirv)

# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/spirv-headers)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/spirv-headers/LICENSE ${CURRENT_PACKAGES_DIR}/share/spirv-headers/copyright)
