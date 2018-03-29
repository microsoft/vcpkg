include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO vurtun/nuklear
    REF 7e710ff4fb0186c0e462d43b30c82cab12ea1277
    SHA512 9f65e2fe2e89521002f7d86e8c5f0947a76724b7e7eb87463832732f38561b0415da98a8411e474467a9e5e1b33189c98f6506cc1baf97dbced66cfe05f2a290
    HEAD_REF master
)
file(INSTALL ${SOURCE_PATH}/nuklear.h DESTINATION ${CURRENT_PACKAGES_DIR}/include)
file(INSTALL ${SOURCE_PATH}/Readme.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/nuklear RENAME copyright)
vcpkg_copy_pdbs()
