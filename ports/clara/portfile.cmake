include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO philsquared/Clara
    REF e3061072fd5a3739fbd11e56ecb7fef5fbd33e04
    SHA512 5ad4b4842153e11b3e82579858c159a85c9ef76e8278ef97befecaedcd79508e89a3fcb5f5b5c3f0ac48064d5627e08cdd2a1db046a95f5b2d55d7b8a4437a92
    HEAD_REF master
)
file(INSTALL ${SOURCE_PATH}/single_include/clara.hpp DESTINATION ${CURRENT_PACKAGES_DIR}/include)
file(INSTALL ${SOURCE_PATH}/single_include/clara.hpp DESTINATION ${CURRENT_PACKAGES_DIR}/share/clara RENAME copyright)
vcpkg_copy_pdbs()