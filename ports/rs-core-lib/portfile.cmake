include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO CaptainCrowbar/rs-core-lib
    REF fda88535dff2193e75bb9d306e4aa38a957b2c91
    SHA512 e1842e2d92b5e935a8d867797d26f998cec628b3030077b8694cc3932546efeac81634e7f6d14189248a945fceb329e24aa39cf830384c04c0d67d2aa6255e57
    HEAD_REF master
)

file(INSTALL ${SOURCE_PATH}/rs-core DESTINATION ${CURRENT_PACKAGES_DIR}/include FILES_MATCHING PATTERN "*.hpp")

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/rs-core-lib RENAME copyright)