include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO vurtun/nuklear
    REF bca152011e3f5839c7eb08864f76f1f900d4ffe7
    SHA512 aa3bf7f9f32fe63140505e4845a9ee22fb9feb1abc3dd36b333697548778272b817795844a8b6f5cc95a4e460afd69fd96359955ab4e8d12737ac4b46be7e4d1
    HEAD_REF master
)
file(INSTALL ${SOURCE_PATH}/nuklear.h DESTINATION ${CURRENT_PACKAGES_DIR}/include)
file(INSTALL ${SOURCE_PATH}/Readme.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/nuklear RENAME copyright)
vcpkg_copy_pdbs()
