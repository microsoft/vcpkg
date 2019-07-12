include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO philsquared/Clara
    REF 161e5b0ff43981ffc20bd0537d50f865361c551d
    SHA512 c3d999f9bb7e80449d0b395973311d00ce948d9db9d2c21c0cb471d8708c6ce317165268d1176a8f3bbaee13ed5ca7a48e7c9076c700ea3bc3fb20771c5871b4
    HEAD_REF master
)
file(INSTALL ${SOURCE_PATH}/single_include/clara.hpp DESTINATION ${CURRENT_PACKAGES_DIR}/include)
file(INSTALL ${SOURCE_PATH}/single_include/clara.hpp DESTINATION ${CURRENT_PACKAGES_DIR}/share/clara RENAME copyright)
vcpkg_copy_pdbs()