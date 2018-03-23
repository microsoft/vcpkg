include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO vurtun/nuklear
    REF 1acb673af13e72d8ac07522a22127ffd33af65a9
    SHA512 8ee7c45d0a6c64062adec3575ea94cf0d5c8d60d9f30cf8c72051c6e9fcf030562379074f37c1f5da256cce8537078694673ed3b947a603982cdbf26c393fa4b
    HEAD_REF master
)
file(INSTALL ${SOURCE_PATH}/nuklear.h DESTINATION ${CURRENT_PACKAGES_DIR}/include)
file(INSTALL ${SOURCE_PATH}/Readme.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/nuklear RENAME copyright)
vcpkg_copy_pdbs()
