vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO eyalz800/zpp_bits
    REF "v${VERSION}"
    SHA512 db3e036a1452b551155ee204ce7e3e6b6a7ab7116142fe434004cdb8d4c910afc9aaed4c3d1d4c831e0c4183a5d9a989d3e538b496d4ef68d1a15684f347c645
    HEAD_REF master
)

file(INSTALL "${SOURCE_PATH}/zpp_bits.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
