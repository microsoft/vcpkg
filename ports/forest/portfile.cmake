include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO xorz57/forest
    REF 11.0.1
    SHA512 cb9245445c52c9e2e544c556cd87ecfd1e598bf0ed71a20368b32bd47b611f9696a8e50e06ecb98814af8e6e254bde9e7f98ca0d28c62f86ce9ff45805c2a1e5
    HEAD_REF master
)

# Handle headers
file(INSTALL ${SOURCE_PATH}/include DESTINATION ${CURRENT_PACKAGES_DIR} FILES_MATCHING PATTERN "*.hpp")

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/forest RENAME copyright)
