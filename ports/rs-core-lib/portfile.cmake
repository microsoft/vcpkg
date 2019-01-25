include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO CaptainCrowbar/rs-core-lib
    REF fa2144ec238def8d5e08d8489fda6ccfe19a8db1
    SHA512 c6c6405a15e197cc7f335e26193b46f00d3293606c042d7d6a2c50e79aa93c9c2ed14537a71b6dad30c271f80138cb7d294bf85bf0e67cbec6c0709e9f0f624f
    HEAD_REF master
)

file(INSTALL ${SOURCE_PATH}/rs-core DESTINATION ${CURRENT_PACKAGES_DIR}/include FILES_MATCHING PATTERN "*.hpp")

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE.TXT DESTINATION ${CURRENT_PACKAGES_DIR}/share/rs-core-lib RENAME copyright)