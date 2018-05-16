#header-only library
include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Microsoft/GSL
    REF d6b26b367b294aca43ff2d28c50293886ad1d5d4
    SHA512 b0190ce7680004c40bf59dab0d4e442f12a69989d707bd94346590c1282277273c6b71db0cf91b4aa1ffa9871bcdd4bed17b5760d9a81a5317fb84c62ea8dc43
    HEAD_REF master
)

file(INSTALL ${SOURCE_PATH}/include/ DESTINATION ${CURRENT_PACKAGES_DIR}/include)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/ms-gsl RENAME copyright)
