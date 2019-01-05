include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO xorz57/forest
    REF 9.0.6
    SHA512 7cb6f25226bbd543332599d5ad2b8e13df6f06342ea12b58ed123ffd81d1362e10c2e01ff95132f7b25431a3ae984bee5cfb86852aa222e1fad1f4e6928f76bc
    HEAD_REF master
)

# Handle headers
file(INSTALL ${SOURCE_PATH}/include DESTINATION ${CURRENT_PACKAGES_DIR} FILES_MATCHING PATTERN "*.hpp")

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/forest RENAME copyright)
