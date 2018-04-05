include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO vurtun/nuklear
    REF 60bd95c926f73b143ec91e66b2fe315ad2a316e1
    SHA512 45cf7c5cab105241aec6c2a56a34abf9701eded52bf06d3092e0079949757a6cbb0d684b45952a054451384cd07a77b1763526470ec84835da3d514c614c65ba
    HEAD_REF master
)
file(INSTALL ${SOURCE_PATH}/nuklear.h DESTINATION ${CURRENT_PACKAGES_DIR}/include)
file(INSTALL ${SOURCE_PATH}/Readme.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/nuklear RENAME copyright)
vcpkg_copy_pdbs()
