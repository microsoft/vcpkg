include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO CaptainCrowbar/rs-core-lib
    REF 73c6a4a9f274ed28588395550224fbd0572ab9ed
    SHA512 92b01c926da565c4ffede85af902013a5bf11c807b5842d73dcbee893f6f7c1e84b49ed2eea75b47477e7b13387e37044de2a1a14ea4255616dd302230787b20
    HEAD_REF master
)

file(INSTALL ${SOURCE_PATH}/rs-core DESTINATION ${CURRENT_PACKAGES_DIR}/include FILES_MATCHING PATTERN "*.hpp")

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE.TXT DESTINATION ${CURRENT_PACKAGES_DIR}/share/rs-core-lib RENAME copyright)