include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO CaptainCrowbar/rs-core-lib
    REF c49c44a14567719e927c942aec7d8e4971aad5bf
    SHA512 17f5cb5d1c60fa832d32f65fce2a1fd00b108d5c1594240543bb6f889c8ddae6dbe83215b63ff15927921bcc9352348340e036c5118278867498216f63e9fef4
    HEAD_REF master
)

file(INSTALL ${SOURCE_PATH}/rs-core DESTINATION ${CURRENT_PACKAGES_DIR}/include FILES_MATCHING PATTERN "*.hpp")

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE.TXT DESTINATION ${CURRENT_PACKAGES_DIR}/share/rs-core-lib RENAME copyright)