include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO vurtun/nuklear
    REF b91a815c826619bfcacacad090e31b2dd3e1a20c
    SHA512 d1966cd01a3d6e75608426f2813ec038dff1291674d481899c031248f0469b47b78f3e35b86a78090e3f019cc478c606d2b78bcc80117fb54de9ed5df22883a0
    HEAD_REF master
)
file(INSTALL ${SOURCE_PATH}/nuklear.h DESTINATION ${CURRENT_PACKAGES_DIR}/include)
file(INSTALL ${SOURCE_PATH}/Readme.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/nuklear RENAME copyright)
vcpkg_copy_pdbs()
