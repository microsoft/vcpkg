include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO philsquared/Clara
    REF 3ba13ad04a3eebc002320f187475ddcd267288a3
    SHA512 d2e73d2ac70f9ad6428f434b101d413453648708d545a1a71f2363b5847e710412b69fdb9ab100eb437f9419cc4c250ce7ca56cfa9132096be9aa471dcb677d0
    HEAD_REF master
)
file(INSTALL ${SOURCE_PATH}/single_include/clara.hpp DESTINATION ${CURRENT_PACKAGES_DIR}/include)
file(INSTALL ${SOURCE_PATH}/single_include/clara.hpp DESTINATION ${CURRENT_PACKAGES_DIR}/share/clara RENAME copyright)
vcpkg_copy_pdbs()