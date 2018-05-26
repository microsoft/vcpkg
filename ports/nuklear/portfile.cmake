include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO vurtun/nuklear
    REF b1209dbb2e087dacb1d5224c3f85675cabbe2330
    SHA512 940730caf6f3732c7846feaf48d3a91538985bc9f0c3b2fea66e395c99c1ca0c6252829152cac3d58dc04d39da19a9aa9b4d9134a6cd1a4ed2594931e22e0461
    HEAD_REF master
)
file(INSTALL ${SOURCE_PATH}/nuklear.h DESTINATION ${CURRENT_PACKAGES_DIR}/include)
file(INSTALL ${SOURCE_PATH}/Readme.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/nuklear RENAME copyright)
vcpkg_copy_pdbs()
