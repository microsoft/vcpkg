# header-only library

include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO JustasMasiulis/xorstr
    REF 5d7371dcb70601ce9c252d475cc3dc6cf8f1e0db
    SHA512 7625d2ebdb95a5414f0a1ac7ac8951b612d5159be5eccce4e13b88a4d17ffa3c65ff81ce5df5b64064b5712da7238ec1f564d2c213852731cad30c367ebad72e
    HEAD_REF master
)

file(COPY ${SOURCE_PATH}/include/xorstr.hpp DESTINATION ${CURRENT_PACKAGES_DIR}/include)

# Handle copyright
configure_file(${SOURCE_PATH}/LICENSE ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)
