# Header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO yhirose/cpp-httplib
    REF v0.9.1
    SHA512 164812075ad516a0a0ad587d7a479e0272fc5eecdbbf4522532dc3039a5282cc120b5b7d75eea3764d21acf203dc1bfccfb9e4f1dfe2515ca4ced546735c28fc
    HEAD_REF master
)

file(
    COPY ${SOURCE_PATH}/httplib.h
    DESTINATION ${CURRENT_PACKAGES_DIR}/include
)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
