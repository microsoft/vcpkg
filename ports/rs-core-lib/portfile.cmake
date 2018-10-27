include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO CaptainCrowbar/rs-core-lib
    REF 5e2e7bb8663d078957a2f6994d9f1e3d4cf50601
    SHA512 d159b11c650572e486ce8376c03e688b5448fdf00d956edf141106d2e1173d86faf0eda843da69687a6f79eb443017dfe0fb1d9f70284444bfda7006d78aee38
    HEAD_REF master
)

file(INSTALL ${SOURCE_PATH}/rs-core DESTINATION ${CURRENT_PACKAGES_DIR}/include FILES_MATCHING PATTERN "*.hpp")

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE.TXT DESTINATION ${CURRENT_PACKAGES_DIR}/share/rs-core-lib RENAME copyright)