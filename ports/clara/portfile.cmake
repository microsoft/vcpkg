include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO philsquared/Clara
    REF a6dfbbd011a79a5f729950d6f4b72c08f9529283
    SHA512 ec3004807c35b54b2defbec7d794817cd90dad5e442fa30c7a4ef3f72d6fcfd789302388bae8752b98d7145071d43851326e476d053b15f800f9117e1a3a0d74
    HEAD_REF master
)
file(INSTALL ${SOURCE_PATH}/single_include/clara.hpp DESTINATION ${CURRENT_PACKAGES_DIR}/include)
file(INSTALL ${SOURCE_PATH}/single_include/clara.hpp DESTINATION ${CURRENT_PACKAGES_DIR}/share/clara RENAME copyright)
vcpkg_copy_pdbs()