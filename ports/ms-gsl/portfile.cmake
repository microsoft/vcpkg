#header-only library
include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Microsoft/GSL
    REF 0cebbd77bfc21acbf1cc05983ad626539eeeb8e0
    SHA512 dd278d4ae1c8b67bea7920006c4671f1277d63a0edd0d017d376b07e1e84115ca07b78b0beb6e18f5ba324d84dd63abb63236fc41d26be1cbc134a56222b7a11
    HEAD_REF master
)

file(INSTALL ${SOURCE_PATH}/include/ DESTINATION ${CURRENT_PACKAGES_DIR}/include)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/ms-gsl RENAME copyright)
