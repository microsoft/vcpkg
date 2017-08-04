include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jarro2783/cxxopts
    REF  v1.3.0
    SHA512 0c02716cdc1ca83f64c3757685042580e06c894ac51986a8df971ed30b8dd6d49448f2c9f61fff947fb34c48055f11cac446b54a9294bc880d78d91081c379b4
    HEAD_REF master
)
file(INSTALL ${SOURCE_PATH}/include/cxxopts.hpp DESTINATION ${CURRENT_PACKAGES_DIR}/include)
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/cxxopts RENAME copyright)
vcpkg_copy_pdbs()
