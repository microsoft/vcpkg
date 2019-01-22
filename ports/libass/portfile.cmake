#header-only library
include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libass/libass
    REF 98727c3b78f44cb3bbc955fcf5d977ebd911d5ca
    SHA512 d466108180cea598b817f89aa21a1021ed2a763580d9aad51b054aa120186af48ab4264907e49ddcb38479a28d87d5431751a28afee9cb83ad7623f002d99c57
    HEAD_REF master
)

file(INSTALL ${SOURCE_PATH}/libass/ DESTINATION ${CURRENT_PACKAGES_DIR}/include/libass)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/libass RENAME copyright)