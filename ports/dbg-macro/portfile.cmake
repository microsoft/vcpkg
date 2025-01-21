# single header file library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO sharkdp/dbg-macro
    REF "v${VERSION}"
    SHA512 9aa41745168409f7c8c9e36e9bae58e2b3b356edd6d5f2414acd7dee9a79d2faa7b63d789821702e33781449b42213855c2ff71dcc39956f5f69c083827118c1
    HEAD_REF master
)

file(COPY "${SOURCE_PATH}/dbg.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include/dbg-macro")

# Handle copyright
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
