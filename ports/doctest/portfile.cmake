#header-only library
include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO onqtam/doctest
    REF 2.0.1
    SHA512 bbd676c8485d9bee4be3f2f6bdd0f72bced09767427533c8de3ea46b298182acaeff64e42683a4283512edd81bb444880b229e65f3296bb4afc8b5b93c03b970
    HEAD_REF master
)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/doctest RENAME copyright)

# Copy header file
file(INSTALL ${SOURCE_PATH}/doctest/doctest.h DESTINATION ${CURRENT_PACKAGES_DIR}/include/doctest)
