# header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO JustasMasiulis/xorstr
    REF a774b984f5b5f15d39ba0a8623cd3c70c05d6007
    SHA512 339fe945e39d27dfc9a9f42bbf4ef008405934668784ee4b661ee9dd04ab0a0bea442c07e7315d1746edd047a6bb7aca7d382314a48fc593633d811cf67bdb2d
    HEAD_REF master
)

file(COPY ${SOURCE_PATH}/include/xorstr.hpp DESTINATION ${CURRENT_PACKAGES_DIR}/include)

# Handle copyright
configure_file(${SOURCE_PATH}/LICENSE ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)
