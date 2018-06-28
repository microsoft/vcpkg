include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO CaptainCrowbar/rs-core-lib
    REF 73826343ba35eca320725925613adc85519a7316
    SHA512 1413e3ad71c20705e3a657fd72ebc6eb7d1f559a865df39d3fcc096316bbb81e6f013c902059ee614869baa632cfb821fe1ceb52508fe3540456a508cabf8d9d
    HEAD_REF master
)

file(INSTALL ${SOURCE_PATH}/rs-core DESTINATION ${CURRENT_PACKAGES_DIR}/include FILES_MATCHING PATTERN "*.hpp")

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE.TXT DESTINATION ${CURRENT_PACKAGES_DIR}/share/rs-core-lib RENAME copyright)