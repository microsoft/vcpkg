#header-only library
include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO skypjack/uvw
    REF v1.11.2_libuv-v1.23
    SHA512 0125233645351b94acb1b42f1632365a60892c64f00b27f04ae76fa523c4ee32c9910f0fcfb160b15269bfb0b5ae0c0f8b46d83a1ca9f9fc661b75eecb7a04d3
)

file(INSTALL
    ${SOURCE_PATH}/src/uvw
    DESTINATION ${CURRENT_PACKAGES_DIR}/include
)

# Handle copyright/readme/package files
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/uvw RENAME copyright)
file(INSTALL ${SOURCE_PATH}/README.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/uvw)
