# header only
include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO vinniefalco/Beast
    REF f68dc343e7c077caee8a95b2a59a2ccb9f979567
    SHA512 d1c4ce5ee4d4b7cb20084c96af87ce106a4474631754a54a7cc19343e0767ed7a14cdb00f27bb1958e35f411b99c90444efd578e8c77e98d7e416703ea6f28bd
    HEAD_REF master
)

file(INSTALL ${SOURCE_PATH}/include/ DESTINATION ${CURRENT_PACKAGES_DIR}/include)
file(INSTALL ${SOURCE_PATH}/LICENSE_1_0.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/beast RENAME copyright)