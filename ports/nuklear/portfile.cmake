include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO vurtun/nuklear
    REF 823f79f856d711eb61af17090af0a623b631e409
    SHA512 6146d2fb26e7d74f9f554619f6a378ecf19ff6a83aa71dba8ee55d194f337c67acae0de7139a4a09736b4685980c9cd85e3c1e99ebf02ee9a306b67b17f185d8
    HEAD_REF master
)
file(INSTALL ${SOURCE_PATH}/nuklear.h DESTINATION ${CURRENT_PACKAGES_DIR}/include)
file(INSTALL ${SOURCE_PATH}/Readme.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/nuklear RENAME copyright)
vcpkg_copy_pdbs()
