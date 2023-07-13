# single header file library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO sharkdp/dbg-macro
    REF "v${VERSION}"
    SHA512 4f785919843026996ffeb3cd8e3494ecd77f42bee104b6659b664b21a3e518739707f5bd006fc8128c99eef241fc6650ad629444f7005df89100a16d8918d05f
    HEAD_REF master
)

file(COPY "${SOURCE_PATH}/dbg.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

# Handle copyright
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
