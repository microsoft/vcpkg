include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO CaptainCrowbar/rs-core-lib
    REF 6123a4ac6c42eadf60404d52d53e19db653f4531
    SHA512 092f19f39d1fd3a7c2866cbd440c15278ab3f0f5c6ff4f30b602b453fd540e0fd8f1145f919c41ac19ce7f7feee94c3ced93e3fe6eeb7caef75cc63872e159cc
    HEAD_REF master
)

file(INSTALL ${SOURCE_PATH}/rs-core DESTINATION ${CURRENT_PACKAGES_DIR}/include FILES_MATCHING PATTERN "*.hpp")

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE.TXT DESTINATION ${CURRENT_PACKAGES_DIR}/share/rs-core-lib RENAME copyright)