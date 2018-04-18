include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO CaptainCrowbar/rs-core-lib
    REF 529b74de173a77ba057ebc54d1f91629e7b643bd
    SHA512 d836ee1c022522618f37fdeba941986977317fa68a909d8255e6abfd39564f72f47f8c78c2fa9e4ccc52da75987b56a02f8f2d5aad2890ef7b93ea843c85940c
    HEAD_REF master
)

file(INSTALL ${SOURCE_PATH}/rs-core DESTINATION ${CURRENT_PACKAGES_DIR}/include FILES_MATCHING PATTERN "*.hpp")

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE.TXT DESTINATION ${CURRENT_PACKAGES_DIR}/share/rs-core-lib RENAME copyright)