include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO yhirose/cpp-httplib
    REF v0.2.2
    SHA512 da666b1e2f442685bfe4509efee1f74a944777a591c4ba6e46bb9e5fae2ddfa176eef6ab86db81149064b39d0002e0eb2b99d1e8c0653bbdef34aff6f79c1fcc
    HEAD_REF master
)

file(
    COPY ${SOURCE_PATH}/httplib.h
    DESTINATION ${CURRENT_PACKAGES_DIR}/include
)

# Handle copyright
configure_file(
    ${SOURCE_PATH}/LICENSE
    ${CURRENT_PACKAGES_DIR}/share/cpp-httplib/copyright
    COPYONLY
)
