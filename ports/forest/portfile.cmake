include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO xorz57/forest
    REF 7.0.3
    SHA512 0e3adde14d9035427f3ca4d40cf6ee9598e8222f0e9884e570cdddf31ceb4fb516c802bf2abfb169e35da6adebfd7514238ca23121871fe9911419449a72cfe0
    HEAD_REF master
)

# Handle headers
file(INSTALL ${SOURCE_PATH}/include DESTINATION ${CURRENT_PACKAGES_DIR} FILES_MATCHING PATTERN "*.h")

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/forest RENAME copyright)
