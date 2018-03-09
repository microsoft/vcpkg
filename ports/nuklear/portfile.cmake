include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO vurtun/nuklear
    REF 905b41f640d5ec901a99d343c95e97104292c2d9
    SHA512 b5d671950f411a99a4f7b0017550cc9448c2ab5743256c949895945664d914b78e35f931c4986d863563391cbee11185b94a03c86737cdbb4b3c4e63e0fdc383
    HEAD_REF master
)
file(INSTALL ${SOURCE_PATH}/nuklear.h DESTINATION ${CURRENT_PACKAGES_DIR}/include)
file(INSTALL ${SOURCE_PATH}/Readme.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/nuklear RENAME copyright)
vcpkg_copy_pdbs()
