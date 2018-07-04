include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO CaptainCrowbar/rs-core-lib
    REF 9bcb33fdfbcd993faaff24fba235f4883209398f
    SHA512 8ef6f58ea7fe81ca53780918b13059f0ca1f62954a0c7e8c62e413e4d3bf6ef2ef01ef60d7bc14d977099e797ca65a31a9d0348c084ec5446566cc69d698ba0b
    HEAD_REF master
)

file(INSTALL ${SOURCE_PATH}/rs-core DESTINATION ${CURRENT_PACKAGES_DIR}/include FILES_MATCHING PATTERN "*.hpp")

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE.TXT DESTINATION ${CURRENT_PACKAGES_DIR}/share/rs-core-lib RENAME copyright)