include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO xorz57/forest
    REF 12.0.0
    SHA512 c6f7a7ca098755bc6ac2f02048962d9f1d619c2d76671e9bb558524f760c3e28604db21991c2d9ebc90ffdb12ea00708d9a4fee1f4416ee216f3ef1dea0a1b97
    HEAD_REF master
)

# Handle headers
file(INSTALL ${SOURCE_PATH}/include DESTINATION ${CURRENT_PACKAGES_DIR} FILES_MATCHING PATTERN "*.hpp")

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/forest RENAME copyright)
