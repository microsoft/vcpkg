include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO andrew-gresyk/HFSM2
    REF Beta7
    SHA512 f3365c0823fa63f7e6b82bd2dc84f8871eb58ffd9485753a60ea8f956856cbec7c5da3929ab8fe8b5902a7c840334a1d421417984124adf109f96756490ac437
    HEAD_REF master
)

# Install include directory
file(INSTALL ${SOURCE_PATH}/include DESTINATION ${CURRENT_PACKAGES_DIR}/include)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright)
