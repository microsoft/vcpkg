include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO vurtun/nuklear
    REF 181cfd86c47ae83eceabaf4e640587b844e613b6
    SHA512 33f6200d046c96b8d42ff851ba788bf4f57d8aa99591b866e8691204378f23d5dce06343521834cd10ffaecc42566d97ce2c3becf48caaadf0cdc270cf69bdbb
    HEAD_REF master
)
file(INSTALL ${SOURCE_PATH}/nuklear.h DESTINATION ${CURRENT_PACKAGES_DIR}/include)
file(INSTALL ${SOURCE_PATH}/Readme.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/nuklear RENAME copyright)
vcpkg_copy_pdbs()
