include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO yhirose/cpp-httplib
    REF v0.2.4
    SHA512 d8b226961f7b9d516b17f2f1c85657a017d63c00d0d2c5478717354cc6f8cfad9a0fb5f189a21242cbeef8579b08a1cd9991271d365afd126cad341f7d5758fd
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
