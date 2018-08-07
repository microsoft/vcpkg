include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO xorz57/forest
    REF 9.0.1
    SHA512 8df45f27942dee9fa9f367ee2bc2b6b89692cf08d208258061ba85848df5729c662f1caf9e44ed995f2e26eb49f5e7b6ec0e910d9dafc4f9b6f66a64a48b046d
    HEAD_REF master
)

# Handle headers
file(INSTALL ${SOURCE_PATH}/include DESTINATION ${CURRENT_PACKAGES_DIR} FILES_MATCHING PATTERN "*.hpp")

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/forest RENAME copyright)
