include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO CaptainCrowbar/rs-core-lib
    REF 971a8ca63bee277ef9826449c9da6233186f54f1
    SHA512 a6ef5ff35684c71e19e10af32d8149c3b80dd26a0f81193f336842ec9f220e0bc249a223066076f0d43c06a540e27c7bc3f3e58bf253672084b917fba2c7cbd9
    HEAD_REF master
)

file(INSTALL ${SOURCE_PATH}/rs-core DESTINATION ${CURRENT_PACKAGES_DIR}/include FILES_MATCHING PATTERN "*.hpp")

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE.TXT DESTINATION ${CURRENT_PACKAGES_DIR}/share/rs-core-lib RENAME copyright)