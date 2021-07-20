# Header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO yhirose/cpp-httplib
    REF v0.8.9
    SHA512 6a3b756235f8a18ef740d0d56b3b8c13959276886e4032a7100656170b2efbdb7897a55a8bce42d38ef62c9a6d8462a9ccffc848320df3abfff24e86d4e7909b
    HEAD_REF master
)

file(
    COPY ${SOURCE_PATH}/httplib.h
    DESTINATION ${CURRENT_PACKAGES_DIR}/include
)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
