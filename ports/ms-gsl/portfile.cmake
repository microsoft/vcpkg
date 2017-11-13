#header-only library
include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Microsoft/GSL
    REF d10ebc6555b627c9d1196076a78467e7be505987
    SHA512 982f1d059f3128e79db7742e4bc9a641f8f6b91e02b00f7a98e4447bff9602501e905bc42173520036a0d3b6ad95ca7908fed15fa200ea01a2bd103b8e9cff88
    HEAD_REF master
)

file(INSTALL ${SOURCE_PATH}/include/ DESTINATION ${CURRENT_PACKAGES_DIR}/include FILES_MATCHING PATTERN "*")

# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/ms-gsl)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/ms-gsl/LICENSE ${CURRENT_PACKAGES_DIR}/share/ms-gsl/copyright)
