include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO philsquared/Clara
    REF 9661f2b4a50895d52ebb4c59382785a2b416c310
    SHA512 0de5bbef3deb2b7a93be02a407ea88ef93a3d60cea4013b80bdb8cf3805e31af1d8598cb7a8415023d7f632b106d510360c61b5df15b09f30d6c045f2add33b3
    HEAD_REF master
)
file(INSTALL ${SOURCE_PATH}/single_include/clara.hpp DESTINATION ${CURRENT_PACKAGES_DIR}/include)
file(INSTALL ${SOURCE_PATH}/single_include/clara.hpp DESTINATION ${CURRENT_PACKAGES_DIR}/share/clara RENAME copyright)
vcpkg_copy_pdbs()