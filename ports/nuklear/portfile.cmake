include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO vurtun/nuklear
    REF 20cd35c0fb379df3b8668e6319e87ada5081c99d
    SHA512 a5cf3ecca15e6a8b8f7a4f7cf1122265831eac1152c6df6495b5e54654e948b05b2e349c46a581b51f6d94bb9c3d4f843f6acaffacd610f54dd45588b8cd5109
    HEAD_REF master
)
file(INSTALL ${SOURCE_PATH}/nuklear.h DESTINATION ${CURRENT_PACKAGES_DIR}/include)
file(INSTALL ${SOURCE_PATH}/Readme.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/nuklear RENAME copyright)
vcpkg_copy_pdbs()
