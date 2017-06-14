# header only
include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO vinniefalco/Beast
    REF 18c68ceec99697121ec442b35dac6c9587a9566a
    SHA512 844acd6543610b17686de5b14631576091336dabdaba0800aa4bba7c6a7d55268cc7bfbcd5337a8a3055011f94cba116bb04ebc2c7e0086b25a63796c2177edd
    HEAD_REF master
)

file(INSTALL ${SOURCE_PATH}/include/ DESTINATION ${CURRENT_PACKAGES_DIR}/include)
file(INSTALL ${SOURCE_PATH}/LICENSE_1_0.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/beast RENAME copyright)