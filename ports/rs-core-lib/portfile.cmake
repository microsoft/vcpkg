include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO CaptainCrowbar/rs-core-lib
    REF 0d70c5fcce34b05aa871bd77241315ff3cbed19f
    SHA512 58753805178ea92c8863636df88c2b25f1eaadcd5f5a626a589141ac1a429208322c9d965577c6d1035ebd881b0c105c9f75e74636a509e60f9e833cc518b5ca
    HEAD_REF master
)

file(INSTALL ${SOURCE_PATH}/rs-core DESTINATION ${CURRENT_PACKAGES_DIR}/include FILES_MATCHING PATTERN "*.hpp")

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE.TXT DESTINATION ${CURRENT_PACKAGES_DIR}/share/rs-core-lib RENAME copyright)