include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO CaptainCrowbar/rs-core-lib
    REF 3434c7f401a6fdc47372960363202228b5cab39b
    SHA512 76be0a078ffbb2c8a4da7d433bd37a0d20a01f75b684931d243d2b3ca5164ea609ec443b6267be631737a9a5187de294f7151c8403e5ee1a3d574362c3c419bf
    HEAD_REF master
)

file(INSTALL ${SOURCE_PATH}/rs-core DESTINATION ${CURRENT_PACKAGES_DIR}/include FILES_MATCHING PATTERN "*.hpp")

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE.TXT DESTINATION ${CURRENT_PACKAGES_DIR}/share/rs-core-lib RENAME copyright)