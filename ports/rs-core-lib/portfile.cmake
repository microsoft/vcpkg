include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO CaptainCrowbar/rs-core-lib
    REF 4e142e1458f20086b3b4269d0537604117769e25
    SHA512 789fdeee5da0e9c64236f9bc0be32121c38a6fc3bec6976751a94ea78bd464a7c9389a5fd112d56eb6c10c7c2dc342276305b8e9831fe880c39f4f5017d26ddc
    HEAD_REF master
)

file(INSTALL ${SOURCE_PATH}/rs-core DESTINATION ${CURRENT_PACKAGES_DIR}/include FILES_MATCHING PATTERN "*.hpp")

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE.TXT DESTINATION ${CURRENT_PACKAGES_DIR}/share/rs-core-lib RENAME copyright)