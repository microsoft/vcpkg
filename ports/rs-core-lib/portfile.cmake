include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO CaptainCrowbar/rs-core-lib
    REF 23ed1ddc676c74f19c333ebbe5dafe68ad3118f3
    SHA512 2b1b0ddb13ba258ce82cb659ca989cb96e9a72ba242df01de7963de50671d6ac6ab93b0e8bb05fa030970e7efb7b894fa4daa7778d77ebb930cba96da3a55317
    HEAD_REF master
)

file(INSTALL ${SOURCE_PATH}/rs-core DESTINATION ${CURRENT_PACKAGES_DIR}/include FILES_MATCHING PATTERN "*.hpp")

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE.TXT DESTINATION ${CURRENT_PACKAGES_DIR}/share/rs-core-lib RENAME copyright)