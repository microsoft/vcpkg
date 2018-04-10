include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO CaptainCrowbar/rs-core-lib
    REF ca8065dea45355836d9ca834823775c23a1f3571
    SHA512 4bead4c2317f8b1f33844eacd052724680da6e00d52acb9238a458598a0745a86e91ac8f41a9b2ec4be1365a18e727e1e2659910f293d3bfe3f3b49d34d20b30
    HEAD_REF master
)

file(INSTALL ${SOURCE_PATH}/rs-core DESTINATION ${CURRENT_PACKAGES_DIR}/include FILES_MATCHING PATTERN "*.hpp")

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE.TXT DESTINATION ${CURRENT_PACKAGES_DIR}/share/rs-core-lib RENAME copyright)