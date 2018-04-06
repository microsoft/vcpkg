include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO CaptainCrowbar/rs-core-lib
    REF 0a500c3a326d1ba177e48ebdb2d71b0a9cd54eae
    SHA512 14642b9c3c4eba8faea434eb94fc19fadbc8e40cbf43ae3591be89b1cd2a0b2f13f93c7ac88d1778d557a185fa6efe5eadf64542da7baf625a39dcb53b0b2313
    HEAD_REF master
)

file(INSTALL ${SOURCE_PATH}/rs-core DESTINATION ${CURRENT_PACKAGES_DIR}/include FILES_MATCHING PATTERN "*.hpp")

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE.TXT DESTINATION ${CURRENT_PACKAGES_DIR}/share/rs-core-lib RENAME copyright)