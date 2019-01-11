include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Tessil/robin-map
    REF v0.2.0
    SHA512 6d16c612a0d646fd08857f2f6ee2909fb607ff05fa9c7733a2b618d662f63bba2f99677b75a09870a1582b7b37f255c4ff1f9171c897c3cfa73dd8879de1ec18
    HEAD_REF master
)

file(COPY ${SOURCE_PATH}/tsl DESTINATION ${CURRENT_PACKAGES_DIR}/include)

file(INSTALL
    ${SOURCE_PATH}/LICENSE
    DESTINATION ${CURRENT_PACKAGES_DIR}/share/robin-map
    RENAME copyright
)
