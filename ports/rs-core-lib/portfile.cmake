include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO CaptainCrowbar/rs-core-lib
    REF 79a54a4eb1b49eca04db31ff779e31a6626d049a
    SHA512 ded381d977b6b84d82f2400cac3e966ef9e27e597aa8ec4846056dabbd55f1be2dab6fd593cd005930e14f83581d10495c2a459bf75b9e05aa6822f3c3eda0a7
    HEAD_REF master
)

file(INSTALL ${SOURCE_PATH}/rs-core DESTINATION ${CURRENT_PACKAGES_DIR}/include FILES_MATCHING PATTERN "*.hpp")

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE.TXT DESTINATION ${CURRENT_PACKAGES_DIR}/share/rs-core-lib RENAME copyright)