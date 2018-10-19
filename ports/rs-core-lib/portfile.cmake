include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO CaptainCrowbar/rs-core-lib
    REF 9ffa126a7ca1a717ffd2c055c5049a15e1507d54
    SHA512 cdb02c546ff4514b63b3467b3296b0e5353ddcce8b774fa8accfbfd6559ab4a258af4822c219a5ce005719216c0c8c8707d377d2ce3ddb7d7a45fd9501787b60
    HEAD_REF master
)

file(INSTALL ${SOURCE_PATH}/rs-core DESTINATION ${CURRENT_PACKAGES_DIR}/include FILES_MATCHING PATTERN "*.hpp")

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE.TXT DESTINATION ${CURRENT_PACKAGES_DIR}/share/rs-core-lib RENAME copyright)