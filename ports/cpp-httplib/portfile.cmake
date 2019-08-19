include(vcpkg_common_functions)

set(VERSION 0.2.0)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO yhirose/cpp-httplib
    REF v0.2.1
    SHA512 f0f24cb58da4bbe4ccaa28891fd56257bc97cdf861c4406f41c0cb0bb76b53f9f707298cb5ea1139e4a819c4b1a4b750090a53652d45c3621b33d76ba627a78f
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
