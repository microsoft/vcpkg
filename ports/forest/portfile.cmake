include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO xorz57/forest
    REF 8.0.1
    SHA512 37ce3d623827be124c0c84c7b70af440a54b4e88a118cffa4a38156bfe66f9c1636c5b640cc6e7fde21702b51a03d5dfa56a349f1937b5a82a5085b4a05142cc
    HEAD_REF master
)

# Handle headers
file(INSTALL ${SOURCE_PATH}/include DESTINATION ${CURRENT_PACKAGES_DIR} FILES_MATCHING PATTERN "*.hpp")

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/forest RENAME copyright)
