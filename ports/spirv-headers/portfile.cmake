
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KhronosGroup/SPIRV-Headers
    REF sdk-1.3.216.0
    SHA512 951715cf62a643bfce6a3854f2206b95dd65e60b27355a2f290e829da0f06e19877e9dfcbf53f455b8a0524fb851a851742f3e16bb29be2f470cd62d3a8fc8f0
    HEAD_REF master
)

# This must be spirv as other spirv packages expect it there.
file(COPY "${SOURCE_PATH}/include/spirv/" DESTINATION "${CURRENT_PACKAGES_DIR}/include/spirv")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
