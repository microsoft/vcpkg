include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO philsquared/Clara
    REF a19db09c015f96f80d282e445ed3091ff20b4248
    SHA512 e7a9574d92ff8cc4b91094d30572bc5b36c30f5dc52c418e76ba2227c526551572f51d4a2fa29e9afab21be82e330070dd8a2118d75bdd49ac1e510755b4cdf4
    HEAD_REF master
)
file(INSTALL ${SOURCE_PATH}/single_include/clara.hpp DESTINATION ${CURRENT_PACKAGES_DIR}/include)
file(INSTALL ${SOURCE_PATH}/single_include/clara.hpp DESTINATION ${CURRENT_PACKAGES_DIR}/share/clara RENAME copyright)
vcpkg_copy_pdbs()