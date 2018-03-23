include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO vurtun/nuklear
    REF 94c0412a086110dc801d83c20be7cb4e89dbd5d1
    SHA512 882bce080ca15a9b789289ceda987f1154df1800fd1428cf1d14db5704caf9ed3842ec1fe345db9548fe5305aa8f8721ddd53e75294b896c8caad061d29ec95a
    HEAD_REF master
)
file(INSTALL ${SOURCE_PATH}/nuklear.h DESTINATION ${CURRENT_PACKAGES_DIR}/include)
file(INSTALL ${SOURCE_PATH}/Readme.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/nuklear RENAME copyright)
vcpkg_copy_pdbs()
