include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO philsquared/Clara
    REF 008c2ae0a52aaa485d6cb830ad54bc6466733298
    SHA512 270c5d8cdc9c833d1a95f1a2737b3db0f537ab92569b5cc1007184b9f7e59f66bbf9ba95313332826814c0b670919b31e27fe797bb3083ac5e55bad6a6051d51
    HEAD_REF master
)
file(INSTALL ${SOURCE_PATH}/single_include/clara.hpp DESTINATION ${CURRENT_PACKAGES_DIR}/include)
file(INSTALL ${SOURCE_PATH}/single_include/clara.hpp DESTINATION ${CURRENT_PACKAGES_DIR}/share/clara RENAME copyright)
vcpkg_copy_pdbs()