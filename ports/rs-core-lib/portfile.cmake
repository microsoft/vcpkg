include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO CaptainCrowbar/rs-core-lib
    REF ae6cde6069cae27079ec36536bc960e119d502e3
    SHA512 79014460c91fa262257e912824cf4528213cec3baebd39b104c52bc162c5fd3040ecf74156aebc428f3a4846d141475ab6a41f28f43edfc06ff7331cb3e93d4a
    HEAD_REF master
)

file(INSTALL ${SOURCE_PATH}/rs-core DESTINATION ${CURRENT_PACKAGES_DIR}/include FILES_MATCHING PATTERN "*.hpp")

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE.TXT DESTINATION ${CURRENT_PACKAGES_DIR}/share/rs-core-lib RENAME copyright)