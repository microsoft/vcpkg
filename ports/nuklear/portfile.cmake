include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO vurtun/nuklear
    REF f42a76e1763117420dac08496151ec4935217a62
    SHA512 ac82026dd79c73bba4f86b6c6889c64b8da88179fb4a92c80c824c5c41652a01eb181d6de23fb4eeb90e0bfc293cae0e760c2f8061920a2d27da1383354a375f
    HEAD_REF master
)
file(INSTALL ${SOURCE_PATH}/nuklear.h DESTINATION ${CURRENT_PACKAGES_DIR}/include)
file(INSTALL ${SOURCE_PATH}/Readme.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/nuklear RENAME copyright)
vcpkg_copy_pdbs()
