include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO philsquared/Clara
    REF a07afba39d1842aa4e43dfae95c59631185163b0
    SHA512 a2334e0f272f897ca16fedf8ffcaabd1bbfdb3f488d161bb9a9aa7b00b0bdbede0144a0a4c3261647d3b73a59db513f92384822a4cbca10501f7d6d6dca6b621
    HEAD_REF master
)
file(INSTALL ${SOURCE_PATH}/single_include/clara.hpp DESTINATION ${CURRENT_PACKAGES_DIR}/include)
file(INSTALL ${SOURCE_PATH}/single_include/clara.hpp DESTINATION ${CURRENT_PACKAGES_DIR}/share/clara RENAME copyright)
vcpkg_copy_pdbs()