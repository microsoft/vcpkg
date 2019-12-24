include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO yhirose/cpp-httplib
    REF v0.4.2
    SHA512 2269bba048790cc37d9dc79de727959d337182ebee50dbacaabcdc495e1a7ef429ad2331c4479b075fd842ba7c3fcef87c487a5c04307e150b747ddd0f04d545
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
