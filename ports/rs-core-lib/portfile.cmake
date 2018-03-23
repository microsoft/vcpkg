include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO CaptainCrowbar/rs-core-lib
    REF c5b4522c336cd2348c9b65b01802ef1c4865fca2
    SHA512 a720d2f4cf6ef9dda1ce3e6bccf1495a8d29d3765d7456a5e8b79342ddc13f68428d17ea1e2993cb181450b0c2dca4c377735eef0f2f2e8a6bd66e6f2b78fd6a
    HEAD_REF master
)

file(INSTALL ${SOURCE_PATH}/rs-core DESTINATION ${CURRENT_PACKAGES_DIR}/include FILES_MATCHING PATTERN "*.hpp")

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE.TXT DESTINATION ${CURRENT_PACKAGES_DIR}/share/rs-core-lib RENAME copyright)