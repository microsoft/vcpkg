#header-only library
include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Microsoft/GSL
    REF 6a33b97a84f9c0a60ede78b5db98647e9a48d6c9
    SHA512 b6a0d062f29c5108f3ad74cdf3337d061d440d60d5d2fd82dd9b299474f9a06ec2b6276a62995fb4e0df1e420052833aa545eb53009a57f968442d814ae67b6c
    HEAD_REF master
)

file(INSTALL ${SOURCE_PATH}/include/ DESTINATION ${CURRENT_PACKAGES_DIR}/include)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/ms-gsl RENAME copyright)
