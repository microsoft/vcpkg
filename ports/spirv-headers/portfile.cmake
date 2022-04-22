
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KhronosGroup/SPIRV-Headers
    REF sdk-1.3.204.1
    SHA512 ef994e0a5232cb21377ed39ef6a941b59eb45524f1d78092a6476245e4e0fb692780e98f5cc2176fdc2fd95430cce523fa376b0eed97042523b5f14a0586955f
    HEAD_REF master
)

# This must be spirv as other spirv packages expect it there.
file(COPY "${SOURCE_PATH}/include/spirv/" DESTINATION "${CURRENT_PACKAGES_DIR}/include/spirv")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
