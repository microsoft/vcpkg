#header-only library
include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Microsoft/GSL
    REF 2fc94db3ebfb1b066edeafac1837f34d6111bff4
    SHA512 b64e454b66570b2139e401e5ffd6042f2d977903cba54fa100246865967457900deee92bfbfa3976bdae555017c044b384a8dfa247946afccd664e2d30204ab2
    HEAD_REF master
)

file(INSTALL ${SOURCE_PATH}/include/ DESTINATION ${CURRENT_PACKAGES_DIR}/include)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/ms-gsl RENAME copyright)
