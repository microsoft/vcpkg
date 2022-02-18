
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KhronosGroup/SPIRV-Headers
    REF bcf55210f13a4fa3c3d0963b509ff1070e434c79
    SHA512 d0553b95f28b77209862059cd0a8c15ca3340f33e13d9bb75340ced07a5aa07b8b9eaa1bdc42daa0dbf78679c3b1ef3d344c73b17518061249cdc67000568c37
    HEAD_REF master
)

# This must be spirv as other spirv packages expect it there.
file(COPY "${SOURCE_PATH}/include/spirv/" DESTINATION "${CURRENT_PACKAGES_DIR}/include/spirv")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
