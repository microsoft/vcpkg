include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO xorz57/forest
    REF 9.0.5
    SHA512 1dd3ae568ea2ce66cab285f392b167a08eef29387fffef3e9283c3ddaf1d461e5f6408cbce17bbaa928ba773a7890ec31f2612e5a2280cc4fe4a02824fbcd4a3
    HEAD_REF master
)

# Handle headers
file(INSTALL ${SOURCE_PATH}/include DESTINATION ${CURRENT_PACKAGES_DIR} FILES_MATCHING PATTERN "*.hpp")

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/forest RENAME copyright)
