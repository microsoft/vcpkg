include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO vurtun/nuklear
    REF 19c14bb777ebccf93fc9ed8a8b295f4a62cb32c9
    SHA512 ff9d9fcbba41b602e13060445dd67a6c07322fce4b9b210cde72e4ba9bb5f3805fec5aad66e2c9aeca191d0fdd4e9b747021e5e8aa62175f927fa39a91847b1a
    HEAD_REF master
)
file(INSTALL ${SOURCE_PATH}/nuklear.h DESTINATION ${CURRENT_PACKAGES_DIR}/include)
file(INSTALL ${SOURCE_PATH}/Readme.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/nuklear RENAME copyright)
vcpkg_copy_pdbs()
