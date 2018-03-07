include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO philsquared/Clara
    REF adb5ec3a5c20defc80286fd6e8c14aeef10fdcd7
    SHA512 93977d8e2024220f37645812dfe1f8a6ab79568c3dc09fa63894d00f440094944a96878178e43b5508aefb7214a6921dad86f9e92b2833f7a1f8c6f53c35860c
    HEAD_REF master
)
file(INSTALL ${SOURCE_PATH}/single_include/clara.hpp DESTINATION ${CURRENT_PACKAGES_DIR}/include)
file(INSTALL ${SOURCE_PATH}/single_include/clara.hpp DESTINATION ${CURRENT_PACKAGES_DIR}/share/clara RENAME copyright)
vcpkg_copy_pdbs()