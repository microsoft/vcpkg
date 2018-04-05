include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO CaptainCrowbar/rs-core-lib
    REF 3300d39fef567adf90f59d07223e55ca44ed4f98
    SHA512 0e696a94ab71ca29c61075d917a26b01057f657537c5516cb3bf2fd046d5c61f7e74d83a7c2eba2d4d923f3bd8b125f61c6732d09ade59b0995f42eb3df22a17
    HEAD_REF master
)

file(INSTALL ${SOURCE_PATH}/rs-core DESTINATION ${CURRENT_PACKAGES_DIR}/include FILES_MATCHING PATTERN "*.hpp")

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE.TXT DESTINATION ${CURRENT_PACKAGES_DIR}/share/rs-core-lib RENAME copyright)