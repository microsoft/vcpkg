include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO xorz57/forest
    REF 4ad0fd111b6667e86bf546a0ce1da5e70b95032c
    SHA512 5b6a3cd2021696a3bb0b0faa169c33931ac222e1e6cd0fd34f37626ddcfe9958b29f9028ba3e6de0f9fb8623a0bfd215525038298d6c7a3b780aa6e1a0fdc4c7
    HEAD_REF master
)

# Handle headers
file(INSTALL ${SOURCE_PATH}/include DESTINATION ${CURRENT_PACKAGES_DIR} FILES_MATCHING PATTERN "*.hpp")

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/forest RENAME copyright)
