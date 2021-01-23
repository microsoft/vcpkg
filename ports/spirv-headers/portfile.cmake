
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KhronosGroup/SPIRV-Headers
    REF 1.5.4.raytracing.fixed
    SHA512 9d8c5ed58ebff603f0cffd1d6156ebafd3a0558e054937d8486bdc9267ad5de5dfd20d9a6f308bfbab77d391094bbc7119f1b05faf72bed41e6aa6fb35a04f5e
    HEAD_REF master
)

# This must be spirv as other spirv packages expect it there.
file(COPY "${SOURCE_PATH}/include/spirv/" DESTINATION "${CURRENT_PACKAGES_DIR}/include/spirv")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
