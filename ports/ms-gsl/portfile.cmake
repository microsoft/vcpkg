#header-only library
include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Microsoft/GSL
    REF 1995e86d1ad70519465374fb4876c6ef7c9f8c61
    SHA512 00d512269f9f126c93882001704c2c1926556d72fd5e26f8ba223d92f09d9955194e7bf08b172483b5d649021b0b7b54eca3e3ea2337e16b4cd5a8313a85ba66
    HEAD_REF master
)

file(INSTALL ${SOURCE_PATH}/include/ DESTINATION ${CURRENT_PACKAGES_DIR}/include)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/ms-gsl RENAME copyright)
