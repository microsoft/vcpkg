#header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO hillbig/esaxx
    REF ca7cb332011ec37a8436487f210f396b84bd8273
    SHA512 8346fc93498f7979fd422db527d0e2db73080b2c372263a72a887ddc8328a29391bce6def5845f4500a180f5c2e641105d0ce108092e6eac9020c6bd67fb46df
)

file(INSTALL
    ${SOURCE_PATH}/esa.hxx
    DESTINATION ${CURRENT_PACKAGES_DIR}/include
)

# Handle copyright/readme/package files
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/esaxx RENAME copyright)
