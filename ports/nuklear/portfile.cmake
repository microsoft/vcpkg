include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO vurtun/nuklear
    REF 2a379bc03879dc22ceb3a03f957fdf4870716cc6
    SHA512 5425267abcd410cf0f2e6d9e7a685eb33289f054b90fc5a9ea9630b5f9c03056c3ca92d0ee00d884806b9b1911bb2b30ebea447278d1eebcdda29347dd547d07
    HEAD_REF master
)
file(INSTALL ${SOURCE_PATH}/nuklear.h DESTINATION ${CURRENT_PACKAGES_DIR}/include)
file(INSTALL ${SOURCE_PATH}/Readme.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/nuklear RENAME copyright)
vcpkg_copy_pdbs()
