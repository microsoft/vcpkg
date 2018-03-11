include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO CaptainCrowbar/rs-core-lib
    REF a0d287aada58586fc16e8cbb44b2d34eaabeff46
    SHA512 4b160552118dccd2faf076e397d59ff785b53ff2ba7fc5f4ccd338dcb7d0eec7e851071036b5c983ad1ddccbcb64653bf522507c687a11756089c054241ff21d
    HEAD_REF master
)

file(INSTALL ${SOURCE_PATH}/rs-core DESTINATION ${CURRENT_PACKAGES_DIR}/include FILES_MATCHING PATTERN "*.hpp")

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE.TXT DESTINATION ${CURRENT_PACKAGES_DIR}/share/rs-core-lib RENAME copyright)