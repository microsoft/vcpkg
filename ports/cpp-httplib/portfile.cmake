include(vcpkg_common_functions)

set(VERSION 0.2.0)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO yhirose/cpp-httplib
    REF 2f8479016fa9af9a63056571992b31c32741d89b
    SHA512 2f17a6a95c849a5c873a65e8da8bf85311f0152e439a973354c24d02ee9e6c3b0f3a456b60f90637ea4588d9ac09f7e41f42199de61315754e5fe9eecbb657ed
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
