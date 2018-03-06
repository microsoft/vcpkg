include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO CaptainCrowbar/rs-core-lib
    REF 5c53913b93ac4109795d5098dabcd241162cd401
    SHA512 ee9ca3071c2bc4c5a5fa44fbdbc1ecca36de96a1bde30ea272772434387bd96e72206a8b91ef2938cab4b1b00363d2838a1715bd524ec6ba7d4a36d328b4ad44
    HEAD_REF master
)

file(INSTALL ${SOURCE_PATH}/rs-core DESTINATION ${CURRENT_PACKAGES_DIR}/include FILES_MATCHING PATTERN "*.hpp")

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE.TXT DESTINATION ${CURRENT_PACKAGES_DIR}/share/rs-core-lib RENAME copyright)